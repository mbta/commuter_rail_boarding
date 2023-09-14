defmodule TrainLoc.Manager do
  @moduledoc """
  Parses and validates incoming events, consults the application's state,
  determines conflicting assignments, updates the application's state,
  and reports conflicts to Splunk Cloud (via Logger).
  """

  use GenStage
  use Timex

  import TrainLoc.Utilities.ConfigHelpers
  alias TrainLoc.Encoder.VehiclePositionsEnhanced
  alias TrainLoc.Manager.BulkEvent
  alias TrainLoc.Vehicles.Vehicle

  require Logger

  # five minutes in milliseconds
  @default_timeout 5 * 60 * 1000
  @stale_data_seconds 30 |> Duration.from_minutes() |> Duration.to_seconds()
  @s3_api Application.compile_env!(:train_loc, :s3_api)

  @type t() :: %__MODULE__{
          time_baseline: (() -> non_neg_integer()),
          excluded_vehicles: [non_neg_integer()],
          producers: [atom()],
          timeout_ref: reference(),
          first_message?: boolean(),
          timeout_after: non_neg_integer(),
          refresh_fn: (atom() -> :ok),
          new_bucket: String.t()
        }

  @type opts() :: [subscribe_to: atom() | nil, timeout_after: non_neg_integer() | nil]

  defstruct [
    :time_baseline,
    :excluded_vehicles,
    :producers,
    :timeout_ref,
    :new_bucket,
    first_message?: true,
    timeout_after: @default_timeout,
    refresh_fn: &ServerSentEventStage.refresh/1
  ]

  @spec start_link(opts()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, opts)
  end

  @spec reset(GenStage.stage()) :: term()
  def reset(pid \\ __MODULE__) do
    GenStage.call(pid, :reset)
  end

  @doc """
  Awaits a reply.
  """
  @spec await(GenStage.stage()) :: term()
  def await(pid \\ __MODULE__) do
    GenStage.call(pid, :await)
  end

  @impl GenStage
  @spec init(opts()) :: {:consumer, t(), [subscribe_to: [atom()]]}
  def init(opts) do
    _ = Logger.debug(fn -> "Starting #{__MODULE__}..." end)
    {time_mod, time_fn} = config(:time_baseline_fn)
    time_baseline_fn = fn -> apply(time_mod, time_fn, []) end
    excluded_vehicles = MapSet.new(config(:excluded_vehicles))

    producers =
      if subscribe_to = Keyword.get(opts, :subscribe_to),
        do: List.wrap(subscribe_to),
        else: []

    state =
      schedule_timeout(%__MODULE__{
        time_baseline: time_baseline_fn,
        excluded_vehicles: excluded_vehicles,
        producers: producers,
        timeout_after: Keyword.get(opts, :timeout_after, %__MODULE__{}.timeout_after),
        new_bucket: Application.get_env(:shared, :new_bucket)
      })

    {:consumer, state, subscribe_to: producers}
  end

  @impl GenStage
  @spec handle_call(:await | :reset, GenServer.from(), t()) :: {:reply, :ok | true, [], t()}
  def handle_call(:reset, _from, state) do
    state = schedule_timeout(state)
    {:reply, :ok, [], %{state | first_message?: true}}
  end

  def handle_call(:await, _from, state) do
    state = schedule_timeout(state)
    {:reply, true, [], state}
  end

  @impl GenStage
  @spec handle_events([term()], GenStage.from() | :from, t()) :: {:noreply, [], t()}
  def handle_events(events, _from, state) do
    state = schedule_timeout(state)
    maybe_refresh!(events, state)

    _ = handle_put_events(events, state)

    {:noreply, [], %{state | first_message?: false}}
  end

  defp handle_put_events(events, state) do
    for event <- events, event.event == "put" do
      Logger.debug(fn ->
        "#{__MODULE__}: received event - #{inspect(event)}"
      end)

      with {:ok, new_vehicles} <- BulkEvent.parse(event.data),
           feed <- generate_feed(new_vehicles, state),
           {:ok, _, _} <- upload_feed(feed, state) do
      else
        {:error, %Jason.DecodeError{} = error} ->
          Logger.error("Failed to decode event: #{inspect(error)}")

        {:error, :invalid_event, event} ->
          Logger.warning("invalid event #{inspect(event)}")

        {:error, error} ->
          Logger.error("Failed to generate feed from event: #{inspect(error)}")
      end
    end
  end

  @impl GenStage
  @spec handle_info({:events, [term()]} | :timeout | term(), t()) :: {:noreply, [], t()}
  def handle_info({:events, events}, state) do
    # only for testing
    handle_events(events, :from, state)
  end

  def handle_info(:timeout, state) do
    Logger.warn(fn -> "#{__MODULE__}: Connection timed out, refreshing..." end)

    Enum.each(state.producers, state.refresh_fn)

    state = schedule_timeout(state)
    {:noreply, [], state}
  end

  def handle_info(msg, state) do
    _ =
      Logger.warn(fn ->
        "#{__MODULE__}: Unknown message received message=#{inspect(msg)}"
      end)

    {:noreply, [], state}
  end

  def upload_feed(feed, state) do
    with result <-
           @s3_api.put_object(
             "commuter_rail_boarding/train_loc/VehiclePositions_enhanced.json",
             feed
           ),
         new_result <-
           @s3_api.put_object("VehiclePositions_enhanced.json", feed, state.new_bucket, []) do
      Logger.info(["Uploaded vehicle locations to S3: ", inspect(result)])
      Logger.info(["Uploaded vehicle locations to new S3 bucket: ", inspect(new_result)])
      {:ok, result, new_result}
    else
      e -> e
    end
  end

  @spec generate_feed([Vehicle.t()], t()) :: binary
  def generate_feed(data, state) do
    data
    |> prune_vehicles(state)
    |> VehiclePositionsEnhanced.encode()
  end

  @spec prune_vehicles([Vehicle.t()], t()) :: [Vehicle.t()]
  def prune_vehicles(vehicles, %{
        time_baseline: time_baseline_fn,
        excluded_vehicles: excluded_vehicles
      }) do
    vehicles
    |> Enum.reject(&(&1.vehicle_id in excluded_vehicles))
    |> reject_stale_vehicles(time_baseline_fn.())
  end

  defp reject_stale_vehicles(vehicles, time_baseline) do
    Enum.reject(vehicles, fn vehicle -> stale?(vehicle, time_baseline) end)
  end

  defp stale?(vehicle, time_baseline) do
    age = time_baseline - Timex.to_unix(vehicle.timestamp)
    age > @stale_data_seconds
  end

  defp schedule_timeout(state) do
    _ =
      if state.timeout_ref do
        Process.cancel_timer(state.timeout_ref)
      end

    ref = Process.send_after(self(), :timeout, state.timeout_after)
    %{state | timeout_ref: ref}
  end

  defp maybe_refresh!(
         events,
         %{producers: producers, refresh_fn: refresh_fn}
       ) do
    if should_refresh?(events) do
      Logger.info("Reauthenticating to Firebase...")
      Enum.each(producers, refresh_fn)
    end
  end

  defp should_refresh?(events) do
    Enum.any?(events, &(&1.event == "auth_revoked"))
  end
end
