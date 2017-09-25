defmodule TrainLoc.Vehicles.State do
    use GenServer
    require Logger
    alias TrainLoc.Vehicles.Vehicles

    #Client Interface

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def all_vehicles(pid \\ __MODULE__) do
        GenServer.call(pid, :all_vehicles)
    end

    def all_vehicle_ids(pid \\ __MODULE__) do
        GenServer.call(pid, :all_ids)
    end

    def update_vehicle(pid \\ __MODULE__, vehicle) do
        GenServer.call(pid, {:update, vehicle})
    end

    def force_update_vehicle(pid \\ __MODULE__, vehicle) do
        GenServer.call(pid, {:force_update, vehicle})
    end

    def get_vehicle(pid \\ __MODULE__, vehicle_id) do
        GenServer.call(pid, {:get, vehicle_id})
    end

    def delete_vehicle(pid \\ __MODULE__, vehicle_id) do
        GenServer.call(pid, {:delete, vehicle_id})
    end

    def purge_vehicles(pid \\ __MODULE__, max_age) do
        GenServer.call(pid, {:purge, max_age})
    end

    def get_duplicate_logons(pid \\ __MODULE__) do
        GenServer.call(pid, :get_duplicates)
    end

    #Server Callbacks

    def init(_) do
        Logger.debug("Starting #{__MODULE__}...")
        {:ok, %{}}
    end

    def handle_call(:all_vehicles, _from, vehicles) do
        {:reply, vehicles, vehicles}
    end

    def handle_call(:all_ids, _from, vehicles) do
        {:reply, Map.keys(vehicles), vehicles}
    end

    def handle_call({:update, vehicle}, _from, vehicles) do
        {:ok, vehicles} = Vehicles.update(vehicles, vehicle)
        {:reply, :ok, vehicles}
    end

    def handle_call({:force_update, vehicle}, _from, vehicles) do
        {:ok, vehicles} = Vehicles.put(vehicles, vehicle)
        {:reply, :ok, vehicles}
    end

    def handle_call({:get, vehicle_id}, _from, vehicles) do
        {:reply, Vehicles.get(vehicles, vehicle_id), vehicles}
    end

    def handle_call({:delete, vehicle_id}, _from, vehicles) do
        {:ok, vehicles} = Vehicles.delete(vehicles, vehicle_id)
        {:reply, :ok, vehicles}
    end

    def handle_call({:purge, max_age}, _from, vehicles) do
        {:ok, vehicles, purged_vehicles} = Vehicles.purge_old_vehicles(vehicles, max_age)
        {:reply, purged_vehicles, vehicles}
    end

    def handle_call(:get_duplicates, _from, vehicles) do
        {:reply, Vehicles.find_duplicate_logons(vehicles), vehicles}
    end
end
