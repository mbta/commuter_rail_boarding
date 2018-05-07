defmodule Busloc.State do
  @moduledoc """
  This module stores the current state of Vehicle locations & assignments
  in a map (keyed on `vehicle_id`) and provides functions for retrieving
  and updating the stored Vehicle data
  """

  use GenServer
  alias Busloc.Vehicle

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  This function is called by Busloc.SamsaraFetcher to update the location and timestamp
  of a Vehicle. The vehicle's block assignment will not change.
  """
  def update(pid \\ __MODULE__, vehicle) when is_map(vehicle) do
    GenServer.call(pid, {:update, vehicle})
  end

  @doc """
  This function is called by Busloc.TmFetcher to reset the state with updated locations
  and block assignments.
  """
  def set(pid \\ __MODULE__, vehicles) when is_list(vehicles) do
    GenServer.call(pid, {:set, vehicles})
  end

  def get_all(pid \\ __MODULE__) do
    GenServer.call(pid, :get_all)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:update, %Vehicle{vehicle_id: id} = new_vehicle}, _from, vehicles) do
    vehicles =
      Map.update(vehicles, id, new_vehicle, fn old_vehicle ->
        if Timex.after?(new_vehicle.timestamp, old_vehicle.timestamp) do
          %{new_vehicle | block: old_vehicle.block}
        else
          old_vehicle
        end
      end)

    {:reply, :ok, vehicles}
  end

  def handle_call({:set, vehicles}, _from, _old_vehicles) do
    new_vehicles = Map.new(vehicles, fn %Vehicle{vehicle_id: id} = veh -> {id, veh} end)
    {:reply, :ok, new_vehicles}
  end

  def handle_call(:get_all, _from, vehicles) do
    {:reply, Map.values(vehicles), vehicles}
  end
end
