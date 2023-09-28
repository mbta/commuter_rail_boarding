defmodule TrainLoc.Encoder.VehiclePositionsEnhancedTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias TrainLoc.Encoder.VehiclePositionsEnhanced
  import TrainLoc.Encoder.VehiclePositionsEnhanced
  alias TrainLoc.Vehicles.Vehicle

  describe "encode/1" do
    test "produces valid GTFS-realtime enhanced JSON from list of vehicles" do
      unix_timestamp = 1_501_844_511
      datetime_timestamp = DateTime.from_unix!(unix_timestamp)

      vehicles = [
        %Vehicle{
          vehicle_id: 1712,
          timestamp: datetime_timestamp,
          trip: "509",
          latitude: 49.24023,
          longitude: -76.12890,
          speed: 0,
          heading: 188
        },
        %Vehicle{
          vehicle_id: 1713,
          timestamp: datetime_timestamp,
          trip: "508",
          latitude: 42.24023,
          longitude: -71.12890,
          speed: 7,
          heading: 270
        },
        %Vehicle{
          vehicle_id: 1714,
          timestamp: datetime_timestamp,
          trip: "507",
          latitude: 52.24023,
          longitude: -61.12890,
          speed: 000,
          heading: 0
        },
        %Vehicle{
          heading: 0.0,
          latitude: 42.240323,
          longitude: -71.128225,
          speed: 0,
          trip: "456",
          timestamp: datetime_timestamp,
          vehicle_id: 1506
        },
        %Vehicle{
          heading: 0.0,
          latitude: 42.240323,
          longitude: -71.127625,
          speed: 0,
          trip: "123",
          timestamp: datetime_timestamp,
          vehicle_id: 1507
        },
        %Vehicle{
          heading: 199.0,
          latitude: 42.23879,
          longitude: -71.13356,
          speed: 1,
          timestamp: datetime_timestamp,
          trip: "745",
          vehicle_id: 1823
        }
      ]

      json = VehiclePositionsEnhanced.encode(vehicles)

      decoded_json = Jason.decode!(json)

      header = decoded_json["header"]
      assert header["gtfs_realtime_version"] == "1.0"
      assert header["incrementality"] == 0
      assert_in_delta(header["timestamp"], System.system_time(:second), 2)

      json_contents = decoded_json["entity"]
      assert length(json_contents) == 6

      for {vehicle, idx} <- Enum.with_index(vehicles) do
        json_content = Enum.at(json_contents, idx)
        json_vehicle_data = json_content["vehicle"]
        json_trip_data = json_vehicle_data["trip"]
        json_position_data = json_vehicle_data["position"]
        expected_speed = miles_per_hour_to_meters_per_second(vehicle.speed)

        assert is_binary(json_content["id"])
        assert json_trip_data["start_date"] == "20170804"
        assert json_trip_data["trip_short_name"] == vehicle.trip
        assert json_vehicle_data["vehicle"]["id"] == Integer.to_string(vehicle.vehicle_id)
        assert json_position_data["latitude"] == vehicle.latitude
        assert json_position_data["longitude"] == vehicle.longitude
        assert json_position_data["bearing"] == vehicle.heading
        assert json_position_data["speed"] == expected_speed
        assert json_vehicle_data["timestamp"] == unix_timestamp
      end
    end

    test "omits 'trip_short_name' field if :unassigned" do
      unix_timestamp = 1_501_844_511
      datetime_timestamp = DateTime.from_unix!(unix_timestamp)

      vehicles = [
        %Vehicle{vehicle_id: 1, trip: "509", timestamp: datetime_timestamp},
        %Vehicle{vehicle_id: 2, trip: :unassigned, timestamp: datetime_timestamp},
        %Vehicle{vehicle_id: 1507, trip: :unassigned, timestamp: datetime_timestamp}
      ]

      json = VehiclePositionsEnhanced.encode(vehicles)

      decoded_json = Jason.decode!(json)

      json_contents = decoded_json["entity"]
      assert length(json_contents) == 3
      [vehicle_1, vehicle_2, vehicle_3] = json_contents
      assert Map.has_key?(vehicle_1["vehicle"]["trip"], "trip_short_name")
      refute Map.has_key?(vehicle_2["vehicle"]["trip"], "trip_short_name")
      refute Map.has_key?(vehicle_3["vehicle"]["trip"], "trip_short_name")
    end
  end

  describe "start_date/1" do
    test "converts DateTime into accurate service date string" do
      test_datetime = %DateTime{
        month: 2,
        day: 2,
        year: 2018,
        hour: 3,
        minute: 30,
        second: 0,
        std_offset: 0,
        utc_offset: -18_000,
        time_zone: "America/New_York",
        zone_abbr: "EST"
      }

      assert VehiclePositionsEnhanced.start_date(test_datetime) == "20180202"
      early_datetime = %DateTime{test_datetime | hour: 0}
      assert VehiclePositionsEnhanced.start_date(early_datetime) == "20180201"
    end

    test "converts UTC datetimes into the appropriate service dates" do
      # 1am EDT
      dt = DateTime.from_naive!(~N[2018-03-22T05:00:00], "Etc/UTC")
      assert start_date(dt) == "20180321"

      # 4am EDT
      dt = DateTime.from_naive!(~N[2018-03-22T08:00:00], "Etc/UTC")
      assert start_date(dt) == "20180322"
    end

    test "converts UTC datestimes into service dates around DST transitions" do
      # spring forward
      assert start_date(DateTime.from_naive!(~N[2018-03-11T06:59:59], "Etc/UTC")) == "20180310"
      assert start_date(DateTime.from_naive!(~N[2018-03-11T07:00:00], "Etc/UTC")) == "20180311"
      assert start_date(DateTime.from_naive!(~N[2018-03-11T08:30:00], "Etc/UTC")) == "20180311"
      assert start_date(DateTime.from_naive!(~N[2018-11-04T06:59:59], "Etc/UTC")) == "20181103"
      assert start_date(DateTime.from_naive!(~N[2018-11-04T07:00:00], "Etc/UTC")) == "20181103"
      assert start_date(DateTime.from_naive!(~N[2018-11-04T08:30:00], "Etc/UTC")) == "20181104"
      assert start_date(DateTime.from_naive!(~N[2018-11-04T09:30:00], "Etc/UTC")) == "20181104"
    end
  end

  defp miles_per_hour_to_meters_per_second(miles_per_hour) do
    miles_per_hour * 0.447
  end
end
