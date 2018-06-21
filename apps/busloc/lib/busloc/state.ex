defmodule Busloc.State do
  @moduledoc """
  This module stores the current state of Vehicle locations & assignments
  in a map (keyed on `vehicle_id`) and provides functions for retrieving
  and updating the stored Vehicle data
  """

  use GenServer

  def start_link(opts \\ []) do
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, name, opts)
  end

  def child_spec(opts) do
    name = Keyword.fetch!(opts, :name)
    spec = super(opts)
    %{spec | id: name}
  end

  @doc """
  This function is called by Busloc.SamsaraFetcher to update the location and timestamp
  of a Vehicle. The vehicle's block assignment will not change.
  """
  def update(table, vehicle) when is_map(vehicle) do
    if old_vehicle = get(table, vehicle.vehicle_id) do
      if not is_nil(vehicle.latitude) && not is_nil(vehicle.longitude) &&
           Timex.after?(vehicle.timestamp, old_vehicle.timestamp) do
        merged_vehicle = merge_keeping_block(old_vehicle, vehicle)
        true = :ets.insert(table, {vehicle.vehicle_id, merged_vehicle})
      end
    else
      :ets.insert(table, {vehicle.vehicle_id, vehicle})
    end
  end

  defp merge_keeping_block(old_vehicle, new_vehicle) do
    %{
      new_vehicle
      | block: old_vehicle.block || new_vehicle.block,
        route: old_vehicle.route || new_vehicle.route,
        trip: old_vehicle.trip || new_vehicle.trip
    }
  end

  defp merge_location(%{latitude: lat, longitude: lon} = new_vehicle, _old_vehicle)
       when is_float(lat) and is_float(lon) do
    new_vehicle
  end

  defp merge_location(new_vehicle, old_vehicle) do
    %{
      new_vehicle
      | latitude: old_vehicle.latitude,
        longitude: old_vehicle.longitude,
        heading: old_vehicle.heading,
        source: old_vehicle.source,
        timestamp: old_vehicle.timestamp
    }
  end

  @doc """
  This function is called by Busloc.TmFetcher to reset the state with updated locations
  and block assignments.
  """
  def set(table, vehicles) when is_list(vehicles) do
    # insert new items
    inserts =
      for vehicle <- vehicles, into: %{} do
        old_vehicle = get(table, vehicle.vehicle_id)
        vehicle = merge_location(vehicle, old_vehicle || vehicle)

        vehicle =
          if old_vehicle && vehicle.timestamp &&
               Timex.after?(old_vehicle.timestamp, vehicle.timestamp) do
            merge_keeping_block(vehicle, old_vehicle)
          else
            vehicle
          end

        {vehicle.vehicle_id, vehicle}
      end

    true = :ets.insert(table, Map.to_list(inserts))
    # delete any items which weren't part of the update
    delete_specs =
      for id <- get_all_ids(table), not Map.has_key?(inserts, id) do
        {{id, :_}, [], [true]}
      end

    _ = :ets.select_delete(table, delete_specs)
    :ok
  end

  def get(table, id) do
    case :ets.lookup(table, id) do
      [{^id, item}] -> item
      [] -> nil
    end
  end

  def get_all(table) do
    :ets.select(table, [{{:_, :"$1"}, [], [:"$1"]}])
  end

  defp get_all_ids(table) do
    :ets.select(table, [{{:"$1", :_}, [], [:"$1"]}])
  end

  def init(table) do
    # set: items have a unique ID
    # named_table: so we can refer to the table by the given name
    # public: so that any process can write to it
    # write_concurrency: faster processing of simultaneous writes
    ^table = :ets.new(table, [:set, :named_table, :public, {:write_concurrency, true}])
    {:ok, :ignored}
  end
end