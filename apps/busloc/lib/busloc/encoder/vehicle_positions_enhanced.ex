defmodule Busloc.Encoder.VehiclePositionsEnhanced do
  @moduledoc """
  Encodes a list of vehicles as an Enhanced JSON VehiclePositions file.
  """
  @behaviour Busloc.Encoder

  @impl Busloc.Encoder
  def encode(vehicles) do
    vehicles
    |> vehicle_positions
    |> Jason.encode!()
  end

  @spec vehicle_positions([Busloc.Vehicle.t()]) :: map
  def vehicle_positions(vehicles) do
    %{
      header: header(),
      entity: Enum.map(vehicles, &entity/1)
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

  @spec entity(Busloc.Vehicle.t()) :: map
  def entity(vehicle) do
    unix_timestamp = DateTime.to_unix(vehicle.timestamp)

    %{
      id: "#{unix_timestamp}_#{vehicle.vehicle_id}",
      is_deleted: false,
      vehicle: %{
        trip: trip(vehicle),
        vehicle: entity_vehicle(vehicle),
        position: %{
          latitude: vehicle.latitude,
          longitude: vehicle.longitude,
          bearing: vehicle.heading,
          speed: vehicle.speed
        },
        operator: %{
          id: vehicle.operator_id,
          name: vehicle.operator_name
        },
        block_id: vehicle.block,
        run_id: vehicle.run,
        location_source: vehicle.source,
        timestamp: unix_timestamp
      }
    }
  end

  defp trip(%{trip: trip_id, route: route_id} = vehicle)
       when is_binary(trip_id) or is_binary(route_id) do
    %{
      trip_id: trip_id(vehicle),
      route_id: vehicle.route,
      schedule_relationship: schedule_relationship(vehicle),
      start_date: start_date(vehicle)
    }
  end

  defp trip(_) do
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

  defp entity_vehicle(%{trip: trip_id} = vehicle) when is_binary(trip_id) do
    %{
      id: "y#{vehicle.vehicle_id}",
      label: vehicle.vehicle_id
    }
  end

  defp entity_vehicle(vehicle) do
    entity = entity_vehicle(%{vehicle | trip: "unassigned"})
    Map.put(entity, :assignment_status, :unassigned)
  end
end
