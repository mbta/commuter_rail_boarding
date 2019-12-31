defmodule TrainLoc.Manager do
  @moduledoc """
  Parses and validates incoming events, consults the application's state,
  determines conflicting assignments, updates the application's state,
  and reports conflicts to Splunk Cloud (via Logger).
  """

  use GenStage
  use Timex

  import TrainLoc.Utilities.ConfigHelpers
  alias TrainLoc.Conflicts.Conflict
  alias TrainLoc.Conflicts.State, as: CState
  alias TrainLoc.Encoder.VehiclePositionsEnhanced
  alias TrainLoc.Logging
  alias TrainLoc.Manager.Event, as: ManagerEvent
  alias TrainLoc.Vehicles.{PreviousBatch, Vehicle}
  alias TrainLoc.Vehicles.State, as: VState
  alias TrainLoc.Vehicles.Validator, as: VehicleValidator

  require Logger

  @stale_data_seconds 30 |> Duration.from_minutes() |> Duration.to_seconds()
  @s3_api Application.get_env(:train_loc, :s3_api)

  def start_link(opts) do
    GenStage.start_link(__MODULE__, opts, opts)
  end

  def reset(pid \\ __MODULE__) do
    GenStage.call(pid, :reset)
  end

  @doc """
  Awaits a reply.
  """
  def await(pid \\ __MODULE__) do
    GenStage.call(pid, :await)
  end

  def init(opts) do
    _ = Logger.debug(fn -> "Starting #{__MODULE__}..." end)
    {time_mod, time_fn} = config(:time_baseline_fn)
    time_baseline_fn = fn -> apply(time_mod, time_fn, []) end
    excluded_vehicles = MapSet.new(config(:excluded_vehicles))

    opts =
      if subscribe_to = Keyword.get(opts, :subscribe_to) do
        [subscribe_to: List.wrap(subscribe_to)]
      else
        []
      end

    {:consumer,
     %{
       first_message?: true,
       time_baseline: time_baseline_fn,
       excluded_vehicles: excluded_vehicles
     }, opts}
  end

  def handle_call(:reset, _from, state) do
    {:reply, :ok, [], %{state | first_message?: true}}
  end

  def handle_call(:await, _from, state) do
    {:reply, true, [], state}
  end

  def handle_events(events, _from, state) do
    for event <- events, event.event == "put" do
      _ =
        Logger.debug(fn ->
          "#{__MODULE__}: received event - #{inspect(event)}"
        end)

      case ManagerEvent.from_string(event.data) do
        {:ok, manager_event} ->
          update_vehicles(manager_event, state)

        {:error, reason} ->
          _ =
            Logger.error(fn ->
              Logging.log_string("Manager Event Parsing Error", reason)
            end)

          :ok
      end
    end

    {:noreply, [], %{state | first_message?: false}}
  end

  def handle_info({:events, events}, state) do
    # only for testing
    handle_events(events, :from, state)
  end

  def handle_info(msg, state) do
    _ =
      Logger.warn(fn ->
        "#{__MODULE__}: Unknown message received message=#{inspect(msg)}"
      end)

    {:noreply, [], state}
  end

  defp update_vehicles(%ManagerEvent{} = manager_event, %{
         first_message?: first_message?,
         time_baseline: time_baseline_fn,
         excluded_vehicles: excluded_vehicles
       }) do
    manager_event.vehicles_json
    |> Enum.reject(&(&1["VehicleID"] in excluded_vehicles))
    |> vehicles_from_data
    |> reject_stale_vehicles(time_baseline_fn.())
    |> VState.upsert_vehicles()

    all_conflicts = VState.get_duplicate_logons()
    {removed_conflicts, new_conflicts} = CState.set_conflicts(all_conflicts)

    if end_of_batch?(manager_event) do
      run_end_of_batch_tasks(all_conflicts)
    end

    possibly_log_conflicts(first_message?, new_conflicts, removed_conflicts)
  end

  defp possibly_log_conflicts(false, new_conflicts, removed_conflicts) do
    Enum.each(new_conflicts, fn c ->
      _ = Logger.info(fn -> "New Conflict - #{Conflict.log_string(c)}" end)
    end)

    Enum.each(removed_conflicts, fn c ->
      _ = Logger.info(fn -> "Resolved Conflict - #{Conflict.log_string(c)}" end)
    end)
  end

  defp possibly_log_conflicts(
         _first_message?,
         _new_conflicts,
         _removed_conflicts
       ) do
    :ok
  end

  def vehicles_from_data(data) when is_list(data) do
    Enum.flat_map(data, &vehicles_from_data/1)
  end

  def vehicles_from_data(json) when is_map(json) do
    vehicle = Vehicle.from_json(json)

    case VehicleValidator.validate(vehicle) do
      :ok ->
        [vehicle]

      {:error, reason} ->
        log_invalid_vehicle(reason)
        []
    end
  end

  defp log_invalid_vehicle(reason) when is_atom(reason) do
    _ =
      Logger.warn(fn ->
        Logging.log_string("Manager Vehicle Validation Failed", reason)
      end)

    :ok
  end

  defp reject_stale_vehicles(vehicles, time_baseline) do
    Enum.reject(vehicles, fn vehicle -> stale?(vehicle, time_baseline) end)
  end

  defp stale?(vehicle, time_baseline) do
    age = time_baseline - Timex.to_unix(vehicle.timestamp)
    age > @stale_data_seconds
  end

  defp end_of_batch?(%ManagerEvent{date: date}) when is_binary(date), do: true
  defp end_of_batch?(_), do: false

  defp run_end_of_batch_tasks(all_conflicts) do
    upload_vehicles_to_s3()
    all_vehicles = VState.all_vehicles()
    end_of_batch_logging(all_conflicts, all_vehicles)
    PreviousBatch.put(all_vehicles)
  end

  defp end_of_batch_logging(all_conflicts, all_vehicles) do
    _ =
      Logger.debug(fn ->
        "#{__MODULE__}: Currently tracking #{length(VState.all_vehicle_ids())} vehicles."
      end)

    _ =
      Logger.debug(fn ->
        "#{__MODULE__}: #{Enum.count(all_vehicles, &Vehicle.active_vehicle?/1)} vehicles active."
      end)

    _ =
      Logger.info(fn ->
        "#{__MODULE__}: Active conflicts:#{length(all_conflicts)}"
      end)

    :ok
  end

  defp upload_vehicles_to_s3 do
    vehicles = VState.all_vehicles()
    json = VehiclePositionsEnhanced.encode(vehicles)
    {:ok, _} = @s3_api.put_object("VehiclePositions_enhanced.json", json)
    :ok
  end
end
