defmodule TrainLoc.Vehicles.VehicleTest do

  use ExUnit.Case, async: true
  use Timex

  alias TrainLoc.Vehicles.Vehicle

  @time_format "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s} {Zname}"

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
end