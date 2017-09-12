defmodule TrainLoc.Supervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

    def init(:ok) do
        children = [
            worker(TrainLoc.Conflicts.State, [[name: TrainLoc.Conflicts.State]]),
            worker(TrainLoc.Vehicles.State, [[name: TrainLoc.Vehicles.State]])
        ]

        supervise(children, strategy: :one_for_one)
    end
end
