defmodule TrainLoc.Vehicles.State do
    use GenServer
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

    def delete_vehicle(pid \\__MODULE__, vehicle_id) do
        GenServer.call(pid, {:delete, vehicle_id})
    end

    #Server Callbacks

    def init(_) do
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
end
