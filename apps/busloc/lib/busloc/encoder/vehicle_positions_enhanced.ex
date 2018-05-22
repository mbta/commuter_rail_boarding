defmodule Busloc.Encoder.VehiclePositionsEnhanced do
  @moduledoc """
  Encodes a list of vehicles as an Enhanced JSON VehiclePositions file.
  """
  @behaviour Busloc.Encoder

  @impl Busloc.Encoder
  def encode(vehicles) do
    vehicles
    |> vehicle_positions
    |> Poison.encode!()
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
        trip: %{
          trip_id: vehicle.trip,
          route_id: vehicle.route
        },
        vehicle: %{
          id: vehicle.vehicle_id
        },
        position: %{
          latitude: vehicle.latitude,
          longitude: vehicle.longitude,
          bearing: vehicle.heading
        },
        block_id: vehicle.block,
        location_source: vehicle.source,
        timestamp: unix_timestamp
      }
    }
  end
end
