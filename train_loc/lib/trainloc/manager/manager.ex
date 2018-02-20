defmodule TrainLoc.Manager do
  @moduledoc """
  Consults the application's state, determines conflicting assignments, updates
  the application's state, and reports conflicts to Splunk Cloud (via Logger).
  """

  use GenServer
  use Timex

  import TrainLoc.Utilities.ConfigHelpers

  alias TrainLoc.Manager
  alias TrainLoc.Vehicles.{Vehicle, Vehicles, Validator}
  alias TrainLoc.Logging
  alias TrainLoc.Conflicts.Conflict
  alias TrainLoc.Vehicles.State, as: VState
  alias TrainLoc.Conflicts.State, as: CState
  alias TrainLoc.Encoder.VehiclePositionsEnhanced

  require Logger

  @stale_data_seconds 30 |> Duration.from_minutes() |> Duration.to_seconds()
  @s3_api Application.get_env(:trainloc, :s3_api)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def reset(pid \\ __MODULE__) do
    GenServer.call(pid, :reset)
  end

  @doc """
  Awaits a reply.
  """
  def await(pid \\ __MODULE__) do
    GenServer.call(pid, :await)
  end

  def init(_) do
    Logger.debug(fn -> "Starting #{__MODULE__}..." end)
    {time_mod, time_fn} = config(:time_baseline_fn)
    time_baseline_fn = fn -> apply(time_mod, time_fn, []) end
    {:ok, %{first_message?: true, time_baseline: time_baseline_fn}}
  end

  def handle_call(:reset, _from, state) do
    {:reply, :ok, %{state | first_message?: true}}
  end

  def handle_call(:await, _from, state) do
    {:reply, true, state}
  end

  def handle_info({:events, events}, state) do
    for event <- events, event.event == "put" do
      Logger.debug(fn -> "#{__MODULE__}: received event - #{inspect event}" end)
      case Manager.Event.from_string(event.data) do
        {:ok, manager_event} ->
          update_vehicles(manager_event, state)
        {:error, reasons} when is_map(reasons) ->
          Logger.error(fn ->
            Logging.log_string("Manager Event Parsing Error", reasons)
          end)
        {:error, reason} when is_atom(reason) when is_binary(reason) ->
          Logger.error(fn ->
            Logging.log_string("Manager Event Parsing Error", %{reason: reason})
          end)
      end
    end

    {:noreply, %{state | first_message?: false}}
  end

  def handle_info(_msg, state) do
    Logger.warn(fn -> "#{__MODULE__}: Unknown message received." end)
    {:noreply, state}
  end

  defp update_vehicles(%Manager.Event{} = manager_event, %{first_message?: first_message?, time_baseline: time_baseline_fn}) do
    manager_event.vehicles_json
    |> vehicles_from_data
    |> Enum.reject(fn v -> time_baseline_fn.() - Timex.to_unix(v.timestamp) > @stale_data_seconds end)
    |> Vehicles.log_assignments()
    |> VState.set_vehicles()
    all_conflicts = VState.get_duplicate_logons()
    {removed_conflicts, new_conflicts} = CState.set_conflicts(all_conflicts)

    if manager_event.date do
      upload_vehicles_to_s3()

      Logger.debug(fn -> "#{__MODULE__}: Currently tracking #{length(VState.all_vehicle_ids)} vehicles." end)
      Logger.debug(fn -> "#{__MODULE__}: #{Enum.count(VState.all_vehicles(), &Vehicle.active_vehicle?/1)} vehicles active." end)
      Logger.info(fn -> "#{__MODULE__}: Active conflicts:#{length(all_conflicts)}" end)
    end

    if not first_message? do
      Enum.each(new_conflicts, fn c ->
        Logger.warn(fn -> "New Conflict - #{Conflict.log_string(c)}" end)
      end)
      Enum.each(removed_conflicts, fn c ->
        Logger.info(fn -> "Resolved Conflict - #{Conflict.log_string(c)}" end)
      end)
    end
  end
  
  def vehicles_from_data(data) when is_list(data) do
    Enum.reduce(data, [], fn (json, acc) when is_map(json) ->
      case vehicles_from_data(json) do
        nil ->
          acc
        %Vehicle{} = vehicle ->
          [ vehicle | acc ]
      end
    end)
  end
  def vehicles_from_data(json) when is_map(json) do
    vehicle = Vehicle.from_json(json)
    case Validator.validate(vehicle) do
      :ok ->
        vehicle
      {:error, reason} ->
        log_invalid_vehicle(reason)
        nil
    end
  end

  defp log_invalid_vehicle(reasons) when is_map(reasons) do
    Logger.error(fn ->
      message = "Manager Vehicle Validation Error"
      reasons = Map.put(reasons, :error_type, "Validation Error")
      Logging.log_string(message, reasons)
    end)
  end
  defp log_invalid_vehicle(reason) when is_atom(reason) when is_binary(reason) do
    log_invalid_vehicle(%{reason: reason})
  end


  defp upload_vehicles_to_s3() do
    vehicles = VState.all_vehicles()
    json = VehiclePositionsEnhanced.encode(vehicles)
    @s3_api.put_object("VehiclePositions_enhanced.json", json)
  end
end
