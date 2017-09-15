defmodule TrainLoc.Manager do
    use GenServer
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Conflicts.Conflict
    alias TrainLoc.Vehicles.State, as: VState
    alias TrainLoc.Conflicts.State, as: CState

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end


    def init(_) do
        {:ok, []}
    end

    def handle_info({:new_file, messages}, _) do
        #Get all "Location" messages, convert them to Vehicle objects, and store them in Vehicles.State
        messages |> Enum.filter(& Map.get(&1, :type)=="Location") |> Enum.map(&Vehicle.from_map(&1)) |> Enum.map(&VState.update_vehicle(&1))

        #Filter list down to only known conflicts
        {removed_conflicts, new_conflicts} = VState.get_duplicate_logons() |> CState.set_conflicts()

        #TODO: Send notification email for each new_conflict
        IO.puts("New Conflicts:")
        new_conflicts |> Enum.each(&IO.puts(Conflict.conflict_string(&1)))

        #TODO: Send "Resolved" email for each removed_conflict
        IO.puts("\nResolved Conflicts:")
        removed_conflicts |> Enum.each(&IO.puts(Conflict.conflict_string(&1)))
    end

    def handle_info(_msg, state) do
        {:noreply, state}
    end
end
