defmodule Busloc.Encoder.VehiclePositionsEnhanced do
  @moduledoc """
  Encodes a list of vehicles as an Enhanced JSON VehiclePositions file.
  """
  @behaviour Busloc.Encoder

  import Busloc.Utilities.Time
  import Busloc.Utilities.ConfigHelpers

  @impl Busloc.Encoder
  def encode(vehicles) do
    vehicles
    |> vehicle_positions
    |> Jason.encode!()
  end

  @spec vehicle_positions([Busloc.Vehicle.t()]) :: map
  def vehicle_positions(vehicles) do
    now = DateTime.utc_now()

    %{
      header: header(),
      entity: Enum.map(vehicles, &entity(&1, now))
    }
  end

  @spec header() :: map
  def header do
    %{
      gtfs_realtime_version: "1.0",
      incrementality: 0,
      timestamp: System.system_time(:seconds)
    }
  end

  @spec entity(Busloc.Vehicle.t(), DateTime.t()) :: map
  def entity(vehicle, now) do
    unix_timestamp = DateTime.to_unix(vehicle.timestamp)

    opts =
      if timestamp_stale(
           vehicle.assignment_timestamp,
           now,
           config(VehiclePositionsEnhanced, :assignment_stale_seconds)
         ) do
        [stale_assignment?: true]
      else
        []
      end

    opts =
      if vehicle_requires_assignment?(
           vehicle,
           config(VehiclePositionsEnhanced, :vehicles_not_requiring_assignment)
         ) do
        opts
      else
        [does_not_need_assignment: true] ++ opts
      end

    %{
      id: "#{unix_timestamp}_#{vehicle.vehicle_id}",
      is_deleted: false,
      vehicle: %{
        position: %{
          latitude: vehicle.latitude,
          longitude: vehicle.longitude,
          bearing: vehicle.heading,
          speed: vehicle.speed
        },
        location_source: vehicle.source,
        timestamp: unix_timestamp,
        trip: trip(vehicle, opts),
        vehicle: entity_vehicle(vehicle, opts),
        operator: entity_operator(vehicle, opts),
        block_id: block(vehicle, opts),
        run_id: run(vehicle, opts)
      }
    }
  end

  defp trip(%{trip: trip_id, route: route_id} = vehicle, [])
       when is_binary(trip_id) or is_binary(route_id) do
    %{
      trip_id: trip_id(vehicle),
      route_id: vehicle.route,
      schedule_relationship: schedule_relationship(vehicle),
      start_date: start_date(vehicle)
    }
  end

  # no trip or route in vehicle, or opts stale_assignment?: true
  defp trip(_, _) do
    %{}
  end

  defp trip_id(%{trip: trip_id}) when is_binary(trip_id) do
    trip_id
  end

  defp trip_id(%{vehicle_id: vehicle_id}) do
    "BL-#{:erlang.phash2(vehicle_id)}"
  end

  defp schedule_relationship(vehicle) do
    if is_binary(vehicle.trip) do
      :SCHEDULED
    else
      :UNSCHEDULED
    end
  end

  defp start_date(%{start_date: %Date{} = date}) do
    Date.to_iso8601(date, :basic)
  end

  defp start_date(_) do
    nil
  end

  # non-nil block, and opts not stale
  defp entity_vehicle(%{block: block_id} = vehicle, [])
       when is_binary(block_id) and block_id != "" do
    %{
      id: "y#{vehicle.vehicle_id}",
      label: vehicle.vehicle_id
    }
  end

  defp entity_vehicle(vehicle, opts) do
    entity = entity_vehicle(%{vehicle | block: "unassigned"}, [])

    if opts[:does_not_need_assignment] do
      entity
    else
      Map.put(entity, :assignment_status, :unassigned)
    end
  end

  # opts not stale
  defp entity_operator(%{operator_id: op_id, operator_name: op_name} = _vehicle, []) do
    %{
      id: op_id,
      name: op_name
    }
  end

  defp entity_operator(_, _) do
    %{id: nil, name: nil}
  end

  # opts not stale
  defp block(vehicle, []) do
    vehicle.block
  end

  defp block(_, _) do
    nil
  end

  # opts not stale
  defp run(vehicle, []) do
    vehicle.run
  end

  defp run(_, _) do
    nil
  end

  defp vehicle_requires_assignment?(%{vehicle_id: id}, [_ | _] = vehicle_ids)
       when is_binary(id) do
    id not in vehicle_ids
  end

  defp vehicle_requires_assignment?(_, _) do
    true
  end
end
