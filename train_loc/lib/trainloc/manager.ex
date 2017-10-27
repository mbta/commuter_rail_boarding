defmodule TrainLoc.Manager do
    @moduledoc """
    Manager module for coordinating the flow of data between the various GenServers
    in the application
    """

    use GenServer

    alias Timex.Duration
    alias TrainLoc.Input.Parser
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Conflicts.Conflict
    alias TrainLoc.Vehicles.State, as: VState
    alias TrainLoc.Conflicts.State, as: CState

    require Logger

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(_) do
        Logger.debug(fn -> "Starting #{__MODULE__}..." end)
        {:ok, true}
    end

    def handle_info({:new_file, file}, is_first_message?) do
        #Get all "Location" messages, convert them to Vehicle objects, and store them in Vehicles.State
        file
        |> Parser.parse
        |> Enum.each(&VState.update_vehicle/1)

        VState.purge_vehicles(Duration.from_minutes(30))
        |> Enum.each(&Logger.info(fn -> "#{__MODULE__}: Vehicle #{&1.vehicle_id} removed due to stale data." end))

        Logger.debug(fn -> "#{__MODULE__}: Currently tracking #{length(VState.all_vehicle_ids)} vehicles." end)
        Logger.debug(fn -> "#{__MODULE__}: #{Enum.count(VState.all_vehicles(), &Vehicle.active_vehicle?/1)} vehicles active." end)

        all_conflicts = VState.get_duplicate_logons()
        Logger.info(fn -> "#{__MODULE__}: Active conflicts:#{length(all_conflicts)}" end)
        {removed_conflicts, new_conflicts} = CState.set_conflicts(all_conflicts)

        if !is_first_message? do
            Enum.each(new_conflicts, &Logger.warn(fn -> "New Conflict - #{Conflict.conflict_string(&1)}" end))
            Enum.each(removed_conflicts, &Logger.info(fn -> "Resolved Conflict - #{Conflict.conflict_string(&1)}" end))
        end

        {:noreply, false}
    end

    def handle_info(_msg, state) do
        {:noreply, state}
    end
end
