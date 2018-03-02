defmodule TrainLoc.Vehicles.VehicleTest do
  use ExUnit.Case, async: true
  use Timex

  import TrainLoc.Utilities.ConfigHelpers
  import ExUnit.CaptureLog
  alias TrainLoc.Vehicles.Vehicle

  @time_format config(:time_format)
  @valid_vehicle_json %{
    "fix" => 1,
    "heading" => 48,
    "latitude" => 4228179,
    "longitude" => -7115936,
    "routename" => "612",
    "speed" => 14,
    "updatetime" => 1515152330,
    "vehicleid" => 1827,
    "workid" => 602,
  }

  # this DateTime is the parsed updatetime from above
  @valid_timestamp Timex.parse!("2018-01-05 11:38:50 America/New_York", @time_format)

  test "converts single JSON object to Vehicle struct" do
    json_obj = %{
      "fix" => 1,
      "heading" => 48,
      "latitude" => 4228179,
      "longitude" => -7115936,
      "routename" => "612",
      "speed" => 14,
      "updatetime" => 1515152330,
      "vehicleid" => 1827,
      "workid" => 602}

    assert Vehicle.from_json_object(json_obj) == [%Vehicle{
      vehicle_id: 1827,
      timestamp: Timex.parse!("2018-01-05 11:38:50 America/New_York", @time_format),
      block: "602",
      trip: "612",
      latitude: 42.28179,
      longitude: -71.15936,
      speed: 14,
      heading: 48,
      fix: 1
    }]
  end

  test "converts batch JSON map to list of Vehicle structs" do
    json_map = %{
      "1633" => %{
        "fix" => 1,
        "heading" => 0,
        "latitude" => 4237405,
        "longitude" => -7107496,
        "routename" => "",
        "speed" => 0,
        "updatetime" => 1516115007,
        "vehicleid" => 1633,
        "workid" => 0
      },
      "1643" => %{
        "fix" => 1,
        "heading" => 168,
        "latitude" => 4272570,
        "longitude" => -7085867,
        "routename" => "170",
        "speed" => 9,
        "updatetime" => 1516114997,
        "vehicleid" => 1643,
        "workid" => 202
      },
      "1652" => %{
        "fix" => 6,
        "heading" => 318,
        "latitude" => 4236698,
        "longitude" => -7106314,
        "routename" => "326",
        "speed" => 10,
        "updatetime" => 1516115003,
        "vehicleid" => 1652,
        "workid" => 306
      }
    }

    assert Vehicle.from_json_map(json_map) == [
      %Vehicle{
        vehicle_id: 1633,
        timestamp: Timex.parse!("2018-01-16 15:03:27 America/New_York", @time_format),
        block: "0",
        trip: "0",
        latitude: 42.37405,
        longitude: -71.07496,
        speed: 0,
        heading: 0,
        fix: 1
      },
      %Vehicle{
        vehicle_id: 1643,
        timestamp: Timex.parse!("2018-01-16 15:03:17 America/New_York", @time_format),
        block: "202",
        trip: "170",
        latitude: 42.72570,
        longitude: -70.85867,
        speed: 9,
        heading: 168,
        fix: 1
      },
      %Vehicle{
        vehicle_id: 1652,
        timestamp: Timex.parse!("2018-01-16 15:03:23 America/New_York", @time_format),
        block: "306",
        trip: "326",
        latitude: 42.36698,
        longitude: -71.06314,
        speed: 10,
        heading: 318,
        fix: 6
      }
    ]
  end

  describe "log_vehicle/1" do
    test "with valid vehicle" do
      iso_8601 = "2015-01-23T23:50:07Z"
      {:ok, datetime, 0} = DateTime.from_iso8601(iso_8601)
      vehicle = %Vehicle{
        vehicle_id: 1712,
        timestamp: datetime,
        block: "802",
        trip: "509",
        latitude: 42.36698,
        longitude: -71.06314,
        speed: 10,
        heading: 318,
        fix: 6
      }
      fun = fn -> Vehicle.log_vehicle(vehicle) end

      expected_logger_message =
        "Vehicle - "
        <> "block=#{vehicle.block} "
        <> "fix=#{vehicle.fix} "
        <> "heading=#{vehicle.heading} "
        <> "latitude=#{vehicle.latitude} "
        <> "longitude=#{vehicle.longitude} "
        <> "speed=#{vehicle.speed} "
        <> "timestamp=#{iso_8601} "
        <> "trip=#{vehicle.trip} "
        <> "vehicle_id=#{vehicle.vehicle_id} "

      assert capture_log(fun) =~ expected_logger_message
    end
  end

  describe "from_json/1" do
    test "works on valid json" do
      expected = %Vehicle{
        block: "602",
        fix: 1,
        heading: 48,
        latitude: 42.28179,
        longitude: -71.15936,
        speed: 14,
        timestamp: @valid_timestamp,
        trip: "612",
        vehicle_id: 1827,
      }
      got = Vehicle.from_json(@valid_vehicle_json)
      assert got == expected
    end

    test "does not fail on invalid json" do
      invalid_json = %{"other" => nil}
      expected = %Vehicle{
        block: "",
        fix: nil,
        heading: nil,
        latitude: nil,
        longitude: nil,
        speed: nil,
        timestamp: nil,
        trip: nil,
        vehicle_id: nil,
      }
      got = Vehicle.from_json(invalid_json)
      assert got == expected
    end

    test "converts lat/long of 0 to nil" do
      json = %{@valid_vehicle_json | "latitude" => 0, "longitude" => 0}
      expected = %Vehicle{
        block: "602",
        fix: 1,
        heading: 48,
        latitude: nil,
        longitude: nil,
        speed: 14,
        timestamp: @valid_timestamp,
        trip: "612",
        vehicle_id: 1827,
      }
      got = Vehicle.from_json(json)
      assert got == expected
    end
  end
end
