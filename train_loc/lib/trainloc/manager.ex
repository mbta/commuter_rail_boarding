defmodule TrainLoc.Manager do
  @moduledoc """
  Consults the application's state, determines conflicting assignments, updates
  the application's state, and reports conflicts to Splunk Cloud (via Logger).
  """

  use GenServer
  use Timex

  import TrainLoc.Utilities.ConfigHelpers

  alias TrainLoc.Vehicles.Vehicle
  alias TrainLoc.Conflicts.Conflict
  alias TrainLoc.Vehicles.State, as: VState
  alias TrainLoc.Conflicts.State, as: CState

  require Logger

  @stale_data_seconds 30 |> Duration.from_minutes() |> Duration.to_seconds()

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def reset(pid \\ __MODULE__) do
    GenServer.call(pid, :reset)
  end

  def empty_message_queue?(pid \\ __MODULE__) do
    GenServer.call(pid, :empty_message_queue?)
  end

  def init(_) do
    Logger.debug(fn -> "Starting #{__MODULE__}..." end)
    {:ok, {true, config(:time_baseline_fn)}}
  end

  def handle_call(:reset, _from, {_, fun}) do
    {:reply, :ok, {true, fun}}
  end

  def handle_call(:empty_message_queue?, _from, state) do
    {:reply, true, state}
  end

  def handle_info({:events, events}, {first_message?, time_baseline_fn}) do
    for event <- events, event.event == "put" do
      Logger.debug(fn -> "#{__MODULE__}: received event - #{inspect event}" end)
      data = Poison.decode!(event.data)["data"]
      updated_vehicles =
        cond do
          is_nil(data) -> []
          first_message? -> Vehicle.from_json_map(data["results"])
          true ->
            if vehicles = Vehicle.from_json_object(data) do
              vehicles
            else
              []
            end
        end

      updated_vehicles
        |> Enum.reject(fn v -> time_baseline_fn.() - Timex.to_unix(v.timestamp) > @stale_data_seconds end)
        |> VState.set_vehicles()
      all_conflicts = VState.get_duplicate_logons()
      {removed_conflicts, new_conflicts} = CState.set_conflicts(all_conflicts)

      if not is_nil(data) and Map.has_key?(data, "date") do
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

    {:noreply, {false, time_baseline_fn}}
  end

  def handle_info(_msg, state) do
    Logger.warn(fn -> "#{__MODULE__}: Unknown message received." end)
    {:noreply, state}
  end
end
