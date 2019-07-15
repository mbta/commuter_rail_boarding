defmodule Busloc.State do
  @moduledoc """
  This module stores the current state of Vehicle locations & assignments
  in a map (keyed on `vehicle_id`) and provides functions for retrieving
  and updating the stored Vehicle data
  """

  use GenServer
  import Busloc.Utilities.ConfigHelpers
  import Busloc.Utilities.Time

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
  This function is called by Busloc.Fetcher.SamsaraFetcher to update the location and timestamp
  of a Vehicle. The vehicle's block assignment will not change.
  """
  def update_location(table, vehicle) when is_map(vehicle) do
    if old_vehicle = get(table, vehicle.vehicle_id) do
      if not is_nil(vehicle.latitude) && not is_nil(vehicle.longitude) &&
           DateTime.compare(vehicle.timestamp, old_vehicle.timestamp) == :gt do
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
        assignment_timestamp:
          old_vehicle.assignment_timestamp || new_vehicle.assignment_timestamp,
        run: old_vehicle.run || new_vehicle.run,
        route: old_vehicle.route || new_vehicle.route,
        trip: old_vehicle.trip || new_vehicle.trip,
        operator_id: old_vehicle.operator_id || new_vehicle.operator_id,
        operator_name: old_vehicle.operator_name || new_vehicle.operator_name
    }
  end

  @doc """
  This function is called by Busloc.Fetcher.AssignedLogonFetcher to insert an assigned logon to Vehicles.
  Or if the Vehicle is present but has no assignment or a stale assignment, it updates the block, run, and operator assignment,
  but does not change the position.
  """
  def update_assigned_logon(table, assigned_logon) when is_map(assigned_logon) do
    now = DateTime.utc_now()

    if old_vehicle = get(table, assigned_logon.vehicle_id) do
      if is_nil(old_vehicle.block) || old_vehicle.block == "" ||
           timestamp_stale(
             old_vehicle.assignment_timestamp,
             now,
             config(AssignedLogonFetcher, :stale_seconds)
           ) do
        merged_vehicle = merge_assignment(old_vehicle, assigned_logon, now)
        true = :ets.insert(table, {old_vehicle.vehicle_id, merged_vehicle})
      end
    else
      new_vehicle = %Busloc.Vehicle{
        vehicle_id: assigned_logon.vehicle_id,
        operator_name: assigned_logon.operator_name,
        operator_id: assigned_logon.operator_id,
        block: assigned_logon.block,
        assignment_timestamp: now,
        run: assigned_logon.run,
        timestamp: now
      }

      :ets.insert(table, {assigned_logon.vehicle_id, new_vehicle})
    end
  end

  defp merge_assignment(old_vehicle, assigned_logon, now) do
    %{
      old_vehicle
      | block: assigned_logon.block,
        assignment_timestamp: now,
        run: assigned_logon.run,
        route: nil,
        trip: nil,
        operator_id: assigned_logon.operator_id,
        operator_name: assigned_logon.operator_name
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

        if old_vehicle && old_vehicle.source != vehicle.source do
          Busloc.Vehicle.AsyncValidator.validate_speed(vehicle, old_vehicle)
        end

        vehicle = merge_location(vehicle, old_vehicle || vehicle)

        vehicle =
          if old_vehicle && vehicle.timestamp &&
               DateTime.compare(old_vehicle.timestamp, vehicle.timestamp) == :gt do
            merge_keeping_block(vehicle, old_vehicle)
          else
            vehicle
          end

        {vehicle.vehicle_id, vehicle}
      end

    true = :ets.insert(table, Map.to_list(inserts))
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

  def init(table) do
    # set: items have a unique ID
    # named_table: so we can refer to the table by the given name
    # public: so that any process can write to it
    # write_concurrency: faster processing of simultaneous writes
    # read_concurrency: faster processing of simultaneous reads
    ^table =
      :ets.new(table, [
        :set,
        :named_table,
        :public,
        {:write_concurrency, true},
        {:read_concurrency, true}
      ])

    {:ok, :ignored}
  end
end
