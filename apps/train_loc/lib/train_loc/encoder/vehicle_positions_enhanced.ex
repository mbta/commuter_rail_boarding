defmodule TrainLoc.Encoder.VehiclePositionsEnhanced do
  @moduledoc """
  Encodes a list of vehicle structs into GTFS-realtime enhanced JSON format.
  """

  import TrainLoc.Utilities.Time

  alias TrainLoc.Vehicles.Vehicle

  @spec encode([Vehicle.t()]) :: String.t()
  def encode(list) when is_list(list) do
    message = %{
      header: feed_header(),
      entity: feed_entity(list)
    }

    Poison.encode!(message)
  end

  defp feed_header do
    %{
      gtfs_realtime_version: "1.0",
      incrementality: 0,
      timestamp: unix_now()
    }
  end

  defp feed_entity(list), do: Enum.map(list, &build_entity/1)

  defp build_entity(%Vehicle{} = vehicle) do
    %{
      id: "#{:erlang.phash2(vehicle)}",
      vehicle: %{
        trip: entity_trip(vehicle),
        vehicle: entity_vehicle(vehicle),
        position: %{
          latitude: vehicle.latitude,
          longitude: vehicle.longitude,
          bearing: vehicle.heading,
          speed: miles_per_hour_to_meters_per_second(vehicle.speed)
        },
        timestamp: format_timestamp(vehicle.timestamp)
      }
    }
  end

  defp build_entity(_), do: []

  defp entity_trip(%{trip: "000"} = vehicle) do
    %{start_date: start_date(vehicle.timestamp)}
  end

  defp entity_trip(%{trip: trip} = vehicle) do
    entity_trip = entity_trip(Map.delete(vehicle, :trip))
    Map.put(entity_trip, :trip_short_name, trip)
  end

  defp entity_trip(vehicle) do
    %{start_date: start_date(vehicle.timestamp)}
  end

  defp entity_vehicle(%{trip: "000"} = vehicle) do
    %{
      id: vehicle.vehicle_id,
      assignment_status: "unassigned"
    }
  end

  defp entity_vehicle(vehicle) do
    %{
      id: vehicle.vehicle_id
    }
  end

  def start_date(%DateTime{} = timestamp) do
    timestamp
    |> get_service_date()
    |> Date.to_iso8601(:basic)
  end

  defp miles_per_hour_to_meters_per_second(miles_per_hour) do
    miles_per_hour * 0.447
  end

  defp format_timestamp(%DateTime{} = timestamp) do
    DateTime.to_unix(timestamp)
  end
end
