defmodule TrainLoc.Vehicles.State do
  @moduledoc """
  GenServer for tracking and querying the vehicles in the system. Each vehicle
  is represented by a `TrainLoc.Vehicles.Vehicle` struct.
  """

  use GenServer

  alias TrainLoc.Vehicles.Vehicles

  require Logger

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

  def get_vehicle(pid \\ __MODULE__, vehicle_id) do
    GenServer.call(pid, {:get, vehicle_id})
  end

  def update_vehicle(pid \\ __MODULE__, vehicle) do
    GenServer.call(pid, {:update, vehicle})
  end

  def set_vehicles(pid \\ __MODULE__, vehicles) do
    GenServer.call(pid, {:set, vehicles})
  end

  def delete_vehicle(pid \\ __MODULE__, vehicle_id) do
    GenServer.call(pid, {:delete, vehicle_id})
  end

  def get_duplicate_logons(pid \\ __MODULE__) do
    GenServer.call(pid, :get_duplicates)
  end

  def reset(pid \\ __MODULE__) do
    GenServer.call(pid, :reset)
  end

  #Server Callbacks

  def init(_) do
    Logger.debug(fn -> "Starting #{__MODULE__}..." end)
    {:ok, Vehicles.new()}
  end

  def handle_call(:all_vehicles, _from, vehicles) do
    {:reply, Vehicles.all_vehicles(vehicles), vehicles}
  end
  def handle_call(:all_ids, _from, vehicles) do
    {:reply, Vehicles.all_ids(vehicles), vehicles}
  end
  def handle_call({:get, vehicle_id}, _from, vehicles) do
    {:reply, Vehicles.get(vehicles, vehicle_id), vehicles}
  end
  def handle_call({:update, vehicle}, _from, vehicles) do
    {:reply, :ok, Vehicles.put(vehicles, vehicle)}
  end
  def handle_call({:set, new_vehicles}, _from, vehicles) do
    vehicles = Vehicles.set(vehicles, new_vehicles)
    {:reply, vehicles, vehicles}
  end
  def handle_call({:delete, vehicle_id}, _from, vehicles) do
    {:reply, :ok, Vehicles.delete(vehicles, vehicle_id)}
  end
  def handle_call(:get_duplicates, _from, vehicles) do
    {:reply, Vehicles.find_duplicate_logons(vehicles), vehicles}
  end
  def handle_call(:reset, _from, _vehicles) do
    {:reply, :ok, Vehicles.new()}
  end

  #Catchalls

  def handle_call(_, _from, vehicles) do
    {:reply, {:error, "Unknown callback."}, vehicles}
  end

  def handle_cast(_, vehicles) do
    {:noreply, vehicles}
  end

  def handle_info(_, vehicles) do
    {:noreply, vehicles}
  end
end
