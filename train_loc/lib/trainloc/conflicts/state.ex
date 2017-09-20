defmodule TrainLoc.Conflicts.State do
    use GenServer
    require Logger
    alias TrainLoc.Conflicts.Conflicts

    #Client Interface

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def all_conflicts(pid \\ __MODULE__) do
        GenServer.call(pid, :all_conflicts)
    end

    def add_conflict(pid \\ __MODULE__, conflict) do
        GenServer.call(pid, {:add, conflict})
    end

    def remove_conflict(pid \\ __MODULE__, conflict) do
        GenServer.call(pid, {:remove, conflict})
    end

    def remove_conflicts(pid \\ __MODULE__, conflicts) do
        GenServer.call(pid, {:remove_many, conflicts})
    end

    def filter_by_field(pid \\ __MODULE__, field, value) do
        GenServer.call(pid, {:filter_by, field, value})
    end

    def set_conflicts(pid \\ __MODULE__, conflicts) do
        GenServer.call(pid, {:set, conflicts})
    end

    #Server Callbacks

    def init(_) do
        Logger.debug("Starting #{__MODULE__}...")
        {:ok, []}
    end

    def handle_call(:all_conflicts, _from, known_conflicts) do
        {:reply, known_conflicts, known_conflicts}
    end

    def handle_call({:add, conflict}, _from, known_conflicts) do
        {:reply, :ok, Conflicts.add(known_conflicts, conflict)}
    end

    def handle_call({:remove, conflict}, _from, known_conflicts) do
        {:reply, :ok, Conflicts.remove(known_conflicts, conflict)}
    end

    def handle_call({:remove_many, conflicts}, _from, known_conflicts) do
        {:reply, :ok, Conflicts.remove_many(known_conflicts, conflicts)}
    end

    def handle_call({:filter_by, field, value}, _from, known_conflicts) do
        {:reply, Conflicts.filter_by(known_conflicts, field, value), known_conflicts}
    end

    def handle_call({:set, new_conflicts}, _from, known_conflicts) do
        {removed, added, known_conflicts} = Conflicts.set(known_conflicts, new_conflicts)
        {:reply, {removed, added}, known_conflicts}
    end
end
