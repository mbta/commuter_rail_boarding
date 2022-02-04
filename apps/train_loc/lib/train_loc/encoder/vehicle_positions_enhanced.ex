defmodule TrainLoc.Encoder.VehiclePositionsEnhanced do
  @moduledoc """
  Encodes a list of vehicle structs into GTFS-realtime enhanced JSON format.
  """

  import TrainLoc.Utilities.Time

  alias TrainLoc.Vehicles.Vehicle

  @type feed() :: %{
          header: feed_header(),
          entity: [entity()]
        }

  @type feed_header() :: %{
          gtfs_realtime_version: String.t(),
          incrementality: integer(),
          timestamp: integer()
        }

  @type entity() :: %{
          id: String.t(),
          vehicle: %{
            trip: entity_trip(),
            vehicle: entity_vehicle(),
            position: %{
              latitude: float() | nil,
              longitude: float() | nil,
              bearing: 0..359,
              speed: float()
            },
            timestamp: non_neg_integer()
          }
        }

  @type entity_trip() :: %{
          :start_date => String.t(),
          optional(:trip_short_name) => String.t()
        }

  @type entity_vehicle() :: %{
          :id => non_neg_integer(),
          optional(:assignment_status) => String.t()
        }

  @spec encode([Vehicle.t()]) :: String.t()
  def encode(list) when is_list(list) do
    list
    |> feed()
    |> Jason.encode!()
  end

  @spec feed([TrainLoc.Vehicles.Vehicle.t()]) :: feed()
  def feed(vehicles) do
    %{header: feed_header(), entity: feed_entity(vehicles)}
  end

  @spec feed_header() :: feed_header()
  defp feed_header do
    %{
      gtfs_realtime_version: "1.0",
      incrementality: 0,
      timestamp: unix_now()
    }
  end

  @spec feed_entity([Vehicle.t()]) :: [entity()]
  defp feed_entity(list), do: Enum.map(list, &build_entity/1)

  @spec build_entity(Vehicle.t()) :: entity() | []
  defp build_entity(vehicle) do
    %{
      id: Integer.to_string(:erlang.phash2(vehicle)),
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

  @spec entity_trip(Vehicle.t()) :: entity_trip()
  defp entity_trip(%{trip: :unassigned} = vehicle) do
    %{start_date: start_date(vehicle.timestamp)}
  end

  defp entity_trip(%{trip: trip} = vehicle) do
    entity_trip = entity_trip(Map.delete(vehicle, :trip))
    Map.put(entity_trip, :trip_short_name, trip)
  end

  defp entity_trip(vehicle) do
    %{start_date: start_date(vehicle.timestamp)}
  end

  @spec entity_vehicle(Vehicle.t()) :: entity_vehicle()
  defp entity_vehicle(vehicle) do
    %{
      id: vehicle.vehicle_id
    }
  end

  @spec start_date(DateTime.t()) :: String.t()
  def start_date(%DateTime{} = timestamp) do
    timestamp
    |> get_service_date()
    |> Date.to_iso8601(:basic)
  end

  @spec miles_per_hour_to_meters_per_second(non_neg_integer()) :: float()
  defp miles_per_hour_to_meters_per_second(miles_per_hour) do
    miles_per_hour * 0.447
  end

  @spec format_timestamp(DateTime.t()) :: integer()
  defp format_timestamp(%DateTime{} = timestamp) do
    DateTime.to_unix(timestamp)
  end
end
