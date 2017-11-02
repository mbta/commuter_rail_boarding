defmodule TrainLoc.Supervisor do
    @moduledoc """
    Supervisor for the vehicle and conflict State GenServers
    """

    use Supervisor

    require Logger

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

    def init(:ok) do
        children = [
            worker(TrainLoc.Conflicts.State, [[name: TrainLoc.Conflicts.State]]),
            worker(TrainLoc.Vehicles.State, [[name: TrainLoc.Vehicles.State]]),
            worker(TrainLoc.Assignments.State, [[name: TrainLoc.Assignments.State]])
        ]

        Logger.debug(fn -> "Starting State supervisor..." end)
        supervise(children, strategy: :one_for_one)
    end
end
