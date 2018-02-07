defmodule TrainLoc.Encoder.VehiclePositionsEnhanced do
  @moduledoc """
  Encodes a list of vehicle structs into GTFS-realtime enhanced JSON format.
  """

  alias TrainLoc.Vehicles.Vehicle

  @spec encode([Vehicle.t]) :: String.t
  def encode(list) when is_list(list) do
    message = %{
      header: feed_header(),
      entity: feed_entity(list)
    }

    Poison.encode!(message)
  end

  defp feed_header do
    timestamp = System.system_time(:seconds)

    %{
      gtfs_realtime_version: "1.0",
      incrementality: 0,
      timestamp: timestamp
    }
  end

  defp feed_entity(list), do: Enum.map(list, &build_entity/1)

  defp build_entity(%Vehicle{} = vehicle) do
    %{
      id: "#{:erlang.phash2(vehicle)}",
      vehicle: %{
        trip: %{
          start_date: start_date(vehicle.timestamp),
          trip_short_name: vehicle.trip,
        },
        vehicle: %{
          "id" => vehicle.vehicle_id
        },
        position: %{
          latitude: vehicle.latitude,
          longitude: vehicle.longitude,
          bearing: vehicle.heading,
          speed: vehicle.speed,
          fix: vehicle.fix,
        },
        timestamp: format_timestamp(vehicle.timestamp),
      }
    }
  end
  defp build_entity(_), do: []

  defp start_date(%NaiveDateTime{} = timestamp) do
    timestamp
    |> NaiveDateTime.to_date()
    |> Date.to_iso8601(:basic)
  end
  defp start_date(%DateTime{} = timestamp) do
    timestamp
    |> DateTime.to_date()
    |> Date.to_iso8601(:basic)
  end

  defp format_timestamp(%NaiveDateTime{} = timestamp) do
    timestamp
    |> DateTime.from_naive!("Etc/UTC")
    |> format_timestamp()
  end
  defp format_timestamp(%DateTime{} = timestamp) do
    DateTime.to_unix(timestamp)
  end
end
