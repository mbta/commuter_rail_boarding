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
    case :ets.lookup(table, vehicle.vehicle_id) do
      [{_, old_vehicle}] ->
        if Timex.after?(vehicle.timestamp, old_vehicle.timestamp) do
          new_vehicle = %{vehicle | block: old_vehicle.block}
          true = :ets.insert(table, {new_vehicle.vehicle_id, new_vehicle})
        else
          :ok
        end

      [] ->
        :ets.insert(table, {vehicle.vehicle_id, vehicle})
    end
  end

  @doc """
  This function is called by Busloc.TmFetcher to reset the state with updated locations
  and block assignments.
  """
  def set(table, vehicles) when is_list(vehicles) do
    # insert new items
    inserts = Map.new(vehicles, &{&1.vehicle_id, &1})
    true = :ets.insert(table, Map.to_list(inserts))
    # delete any items which weren't part of the update
    delete_specs =
      for id <- get_all_ids(table), not Map.has_key?(inserts, id) do
        {{id, :_}, [], [true]}
      end

    _ = :ets.select_delete(table, delete_specs)
    :ok
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
