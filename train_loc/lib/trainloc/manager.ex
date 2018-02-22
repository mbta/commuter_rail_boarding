defmodule TrainLoc.Manager do
  @moduledoc """
  Consults the application's state, determines conflicting assignments, updates
  the application's state, and reports conflicts to Splunk Cloud (via Logger).
  """

  use GenServer
  use Timex

  import TrainLoc.Utilities.ConfigHelpers

  alias TrainLoc.Vehicles.Vehicle
  alias TrainLoc.Vehicles.PreviousBatch
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

  def handle_info({:events, events}, %{first_message?: first_message?, time_baseline: time_baseline_fn} = state) do
    for event <- events, event.event == "put" do
      Logger.debug(fn -> "#{__MODULE__}: received event - #{inspect event}" end)
      data = Poison.decode!(event.data)["data"]
      updated_vehicles = vehicles_from_data(data, first_message?)

      updated_vehicles
      |> reject_stale_vehicles(time_baseline_fn.())
      |> VState.upsert_vehicles()
      all_conflicts = VState.get_duplicate_logons()
      {removed_conflicts, new_conflicts} = CState.set_conflicts(all_conflicts)

      if end_of_batch?(data) do
        run_end_of_batch_tasks(all_conflicts)
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

    {:noreply, %{state | first_message?: false}}
  end

  def handle_info(_msg, state) do
    Logger.warn(fn -> "#{__MODULE__}: Unknown message received." end)
    {:noreply, state}
  end

  defp vehicles_from_data(nil, _), do: []
  defp vehicles_from_data(data, true) do
    Vehicle.from_json_map(data["results"])
  end
  defp vehicles_from_data(data, _) do
    Vehicle.from_json_object(data)
  end

  defp reject_stale_vehicles(vehicles, time_baseline) do
    Enum.reject(vehicles, fn vehicle -> stale?(vehicle, time_baseline) end)
  end

  defp stale?(vehicle, time_baseline) do
    age = time_baseline - Timex.to_unix(vehicle.timestamp)
    age > @stale_data_seconds
  end

  defp end_of_batch?(%{"date" => _date}), do: true
  defp end_of_batch?(_), do: false

  defp run_end_of_batch_tasks(all_conflicts) do
    upload_vehicles_to_s3()
    all_vehicles = VState.all_vehicles()
    end_of_batch_logging(all_conflicts, all_vehicles)
    PreviousBatch.put(all_vehicles)
  end

  defp end_of_batch_logging(all_conflicts, all_vehicles) do
    Logger.debug(fn -> "#{__MODULE__}: Currently tracking #{length(VState.all_vehicle_ids)} vehicles." end)
    Logger.debug(fn -> "#{__MODULE__}: #{Enum.count(all_vehicles, &Vehicle.active_vehicle?/1)} vehicles active." end)
    Logger.info(fn -> "#{__MODULE__}: Active conflicts:#{length(all_conflicts)}" end)
  end

  defp upload_vehicles_to_s3() do
    vehicles = VState.all_vehicles()
    json = VehiclePositionsEnhanced.encode(vehicles)
    @s3_api.put_object("VehiclePositions_enhanced.json", json)
  end
end
