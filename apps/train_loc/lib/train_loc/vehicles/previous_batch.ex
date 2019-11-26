defmodule TrainLoc.Vehicles.PreviousBatch do
  @moduledoc """
  Keeps track of vehicle data received in the previously processed Keolis batch.

  """
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def put(pid \\ __MODULE__, vehicles) do
    GenServer.call(pid, {:put, vehicles})
  end

  def only_old_locations_warning do
    "Keolis API Error - Only old locations in Keolis batch"
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:put, new_vehicles}, _from, old_vehicles) do
    if new_vehicles == old_vehicles do
      Logger.error(fn -> only_old_locations_warning() end)
    end

    {:reply, :ok, new_vehicles}
  end
end
