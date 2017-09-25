defmodule TrainLoc.Manager do
    use GenServer
    require Logger
    alias Timex.Duration
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Conflicts.Conflict
    alias TrainLoc.Vehicles.State, as: VState
    alias TrainLoc.Conflicts.State, as: CState

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end


    def init(_) do
        Logger.debug("Starting #{__MODULE__}...")
        {:ok, []}
    end

    def handle_info({:new_file, messages}, state) do
        #Get all "Location" messages, convert them to Vehicle objects, and store them in Vehicles.State
        messages |> Enum.filter(&is_relevant_message?(&1)) |> Enum.map(&Vehicle.from_map(&1)) |> Enum.each(&VState.update_vehicle(&1))
        #VState.purge_vehicles(Duration.from_hours(2)) |> Enum.each(&Logger.info("Vehicle #{&1.vehicle_id} removed due to stale data."))

        #Filter list down to only known conflicts
        {removed_conflicts, new_conflicts} = VState.get_duplicate_logons() |> CState.set_conflicts()

        new_conflicts |> Enum.each(&Logger.warn("New Conflict - #{Conflict.conflict_string(&1)}"))
        removed_conflicts |> Enum.each(&Logger.info("Resolved Conflict - #{Conflict.conflict_string(&1)}"))
        {:noreply, state}
    end

    def handle_info(_msg, state) do
        {:noreply, state}
    end

    @spec is_relevant_message?(map) :: boolean
    def is_relevant_message?(message) do
        Map.get(message, :type) == "Location"
    end
end
