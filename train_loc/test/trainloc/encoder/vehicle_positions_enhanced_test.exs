defmodule TrainLoc.Encoder.VehiclePositionsEnhancedTest do
  use ExUnit.Case, async: true

  alias TrainLoc.Vehicles.Vehicle
  alias TrainLoc.Encoder.VehiclePositionsEnhanced

  describe "encode/1" do
    test "produces valid GTFS-realtime enhanced JSON from list of vehicles" do
      vehicles = [
        %Vehicle{
          vehicle_id: 1712,
          timestamp: ~N[2017-08-04 11:01:51],
          trip: "509",
          latitude: 49.24023,
          longitude: -76.12890,
          speed: 0,
          heading: 188,
          fix: 1
        },
        %Vehicle{
          vehicle_id: 1713,
          timestamp: ~N[2017-08-04 11:01:51],
          trip: "508",
          latitude: 42.24023,
          longitude: -71.12890,
          speed: 7,
          heading: 270,
          fix: 1
        },
        %Vehicle{
          vehicle_id: 1714,
          timestamp: ~N[2017-08-04 11:01:51],
          trip: "507",
          latitude: 52.24023,
          longitude: -61.12890,
          speed: 000,
          heading: 0,
          fix: 1
        }
      ]

      json = VehiclePositionsEnhanced.encode(vehicles)

      decoded_json = Poison.decode!(json)

      header = decoded_json["header"]
      assert header["gtfs_realtime_version"] == "1.0"
      assert header["incrementality"] == 0
      assert_in_delta(header["timestamp"], System.system_time(:seconds), 1)

      json_contents = decoded_json["entity"]
      assert length(json_contents) == 3
      for {vehicle, idx} <- Enum.with_index(vehicles) do
        json_content = Enum.at(json_contents, idx)
        json_vehicle_data = json_content["vehicle"]
        json_trip_data = json_vehicle_data["trip"]
        json_position_data = json_vehicle_data["position"]

        assert is_binary(json_content["id"])
        assert json_trip_data["start_date"] == "20170804"
        assert json_trip_data["trip_short_name"] == vehicle.trip
        assert json_vehicle_data["vehicle"]["id"] == vehicle.vehicle_id
        assert json_position_data["latitude"] == vehicle.latitude
        assert json_position_data["longitude"] == vehicle.longitude
        assert json_position_data["bearing"] == vehicle.heading
        assert json_position_data["speed"] == vehicle.speed
        assert json_position_data["fix"] == vehicle.fix
        assert json_vehicle_data["timestamp"] == to_unix(vehicle.timestamp)
      end
    end

    defp to_unix(naivedatetime) do
      naivedatetime
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_unix()
    end
  end
end
