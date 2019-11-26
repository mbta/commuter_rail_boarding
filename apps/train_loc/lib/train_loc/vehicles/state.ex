defmodule TrainLoc.Vehicles.State do
  @moduledoc """
  GenServer for tracking and querying the vehicles in the system. Each vehicle
  is represented by a `TrainLoc.Vehicles.Vehicle` struct.
  """

  use GenServer

  alias TrainLoc.Vehicles.Vehicles

  require Logger

  # Client Interface

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def all_vehicles(pid \\ __MODULE__) do
    GenServer.call(pid, :all_vehicles)
  end

  def all_vehicle_ids(pid \\ __MODULE__) do
    GenServer.call(pid, :all_ids)
  end

  def upsert_vehicles(pid \\ __MODULE__, vehicles) do
    GenServer.call(pid, {:upsert_vehicles, vehicles})
  end

  def get_duplicate_logons(pid \\ __MODULE__) do
    GenServer.call(pid, :get_duplicates)
  end

  def reset(pid \\ __MODULE__) do
    GenServer.call(pid, :reset)
  end

  @doc """
  Awaits a reply.
  """
  def await(pid \\ __MODULE__) do
    GenServer.call(pid, :await)
  end

  # Server Callbacks

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

  def handle_call({:upsert_vehicles, new_vehicles}, _from, vehicles) do
    vehicles = Vehicles.upsert(vehicles, new_vehicles)
    {:reply, vehicles, vehicles}
  end

  def handle_call(:get_duplicates, _from, vehicles) do
    {:reply, Vehicles.find_duplicate_logons(vehicles), vehicles}
  end

  def handle_call(:reset, _from, _vehicles) do
    {:reply, :ok, Vehicles.new()}
  end

  def handle_call(:await, _from, state) do
    {:reply, true, state}
  end

  # Catchalls

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
