defmodule TrainLoc.Encoder.VehiclePositionsEnhancedTest do
  use ExUnit.Case, async: true

  alias TrainLoc.Vehicles.Vehicle
  alias TrainLoc.Encoder.VehiclePositionsEnhanced

  describe "encode/1" do
    test "produces valid GTFS-realtime enhanced JSON from list of vehicles" do
      unix_timestamp = 1501844511
      datetime_timestamp = DateTime.from_unix!(unix_timestamp)

      vehicles = [
        %Vehicle{
          vehicle_id: 1712,
          timestamp: datetime_timestamp,
          trip: "509",
          latitude: 49.24023,
          longitude: -76.12890,
          speed: 0,
          heading: 188,
          fix: 1
        },
        %Vehicle{
          vehicle_id: 1713,
          timestamp: datetime_timestamp,
          trip: "508",
          latitude: 42.24023,
          longitude: -71.12890,
          speed: 7,
          heading: 270,
          fix: 1
        },
        %Vehicle{
          vehicle_id: 1714,
          timestamp: datetime_timestamp,
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
        expected_speed = miles_per_hour_to_meters_per_second(vehicle.speed)

        assert is_binary(json_content["id"])
        assert json_trip_data["start_date"] == "20170804"
        assert json_trip_data["trip_short_name"] == vehicle.trip
        assert json_vehicle_data["vehicle"]["id"] == vehicle.vehicle_id
        assert json_position_data["latitude"] == vehicle.latitude
        assert json_position_data["longitude"] == vehicle.longitude
        assert json_position_data["bearing"] == vehicle.heading
        assert json_position_data["speed"] == expected_speed
        assert json_position_data["fix"] == vehicle.fix
        assert json_vehicle_data["timestamp"] == unix_timestamp
      end
    end
  end

  describe "start_date/1" do
    test "converts DateTime into accurate service date string" do
      test_datetime = %DateTime{
        month: 2, day: 2, year: 2018,
        hour: 3, minute: 30, second: 0,
        std_offset: 0, utc_offset: -18000,
        time_zone: "America/New_York", zone_abbr: "EST"
      }
      assert VehiclePositionsEnhanced.start_date(test_datetime) == "20180202"
      early_datetime = %DateTime{test_datetime | hour: 0}
      assert VehiclePositionsEnhanced.start_date(early_datetime) == "20180201"
    end
  end

  defp miles_per_hour_to_meters_per_second(miles_per_hour) do
    miles_per_hour * 0.447
  end
end
