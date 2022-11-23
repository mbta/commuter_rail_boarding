defmodule TrainLoc.Vehicles.VehicleTest do
  use ExUnit.Case, async: true
  use Timex

  import Jason.Sigil
  import TrainLoc.Utilities.ConfigHelpers
  import ExUnit.CaptureLog
  alias TrainLoc.Vehicles.Vehicle

  @valid_vehicle_json %{
    "Heading" => 48,
    "Latitude" => 42.28179,
    "Longitude" => -71.15936,
    "TripID" => 612,
    "Speed" => 14,
    "Update Time" => "2018-01-05T11:38:50.000Z",
    "VehicleID" => 1827,
    "WorkID" => 602
  }

  # this DateTime is the parsed updatetime from above
  @valid_timestamp ~U[2018-01-05 11:38:50Z]

  describe "from_json_object/1" do
    test "converts single JSON object to Vehicle struct" do
      json_obj = %{
        "Heading" => 48,
        "Latitude" => 42.28179,
        "Longitude" => -71.15936,
        "TripID" => 612,
        "Speed" => 14,
        "Update Time" => "2018-01-05T11:38:50.000Z",
        "VehicleID" => 1827,
        "WorkID" => 602
      }

      assert Vehicle.from_json_object(json_obj) == [
               %Vehicle{
                 vehicle_id: 1827,
                 timestamp: ~U[2018-01-05 11:38:50Z],
                 block: "602",
                 trip: "612",
                 latitude: 42.28179,
                 longitude: -71.15936,
                 speed: 14,
                 heading: 48
               }
             ]
    end
  end

  describe "from_json_map/1" do
    test "converts batch JSON map to list of Vehicle structs" do
      json_map = %{
        "1633" => %{
          "Heading" => 0,
          "Latitude" => 42.37405,
          "Longitude" => -71.07496,
          "TripID" => 0,
          "Speed" => 0,
          "Update Time" => "2018-01-16T15:03:27.000Z",
          "VehicleID" => 1633,
          "WorkID" => 0
        },
        "1643" => %{
          "Heading" => 168,
          "Latitude" => 42.72570,
          "Longitude" => -70.85867,
          "TripID" => 170,
          "Speed" => 9,
          "Update Time" => "2018-01-16T15:03:17.000Z",
          "VehicleID" => 1643,
          "WorkID" => 202
        },
        "1652" => %{
          "Heading" => 318,
          "Latitude" => 42.36698,
          "Longitude" => -71.06314,
          "TripID" => 326,
          "Speed" => 10,
          "Update Time" => "2018-01-16T15:03:23.000Z",
          "VehicleID" => 1652,
          "WorkID" => 306
        }
      }

      assert Vehicle.from_json_map(json_map) == [
               %Vehicle{
                 vehicle_id: 1633,
                 timestamp: ~U[2018-01-16 15:03:27Z],
                 block: :unassigned,
                 trip: :unassigned,
                 latitude: 42.37405,
                 longitude: -71.07496,
                 speed: 0,
                 heading: 0
               },
               %Vehicle{
                 vehicle_id: 1643,
                 timestamp: ~U[2018-01-16 15:03:17Z],
                 block: "202",
                 trip: "170",
                 latitude: 42.72570,
                 longitude: -70.85867,
                 speed: 9,
                 heading: 168
               },
               %Vehicle{
                 vehicle_id: 1652,
                 timestamp: ~U[2018-01-16 15:03:23Z],
                 block: "306",
                 trip: "326",
                 latitude: 42.36698,
                 longitude: -71.06314,
                 speed: 10,
                 heading: 318
               }
             ]
    end
  end

  describe "log_vehicle/1" do
    test "with valid vehicle" do
      iso_8601 = "2015-01-23T23:50:07.000Z"
      {:ok, datetime, 0} = DateTime.from_iso8601(iso_8601)

      vehicle = %Vehicle{
        vehicle_id: 1712,
        timestamp: datetime,
        block: "802",
        trip: "509",
        latitude: 42.36698,
        longitude: -71.06314,
        speed: 10,
        heading: 318
      }

      fun = fn -> Vehicle.log_vehicle(vehicle) end

      expected_logger_message =
        "Vehicle - " <>
          "block=#{vehicle.block} " <>
          "heading=#{vehicle.heading} " <>
          "latitude=#{vehicle.latitude} " <>
          "longitude=#{vehicle.longitude} " <>
          "speed=#{vehicle.speed} " <>
          "timestamp=#{iso_8601} " <>
          "trip=#{vehicle.trip} " <> "vehicle_id=#{vehicle.vehicle_id} "

      assert capture_log(fun) =~ expected_logger_message
    end
  end

  describe "from_json/1" do
    test "works on valid json" do
      expected = %Vehicle{
        block: "602",
        heading: 48,
        latitude: 42.28179,
        longitude: -71.15936,
        speed: 14,
        timestamp: @valid_timestamp,
        trip: "612",
        vehicle_id: 1827
      }

      got = Vehicle.from_json(@valid_vehicle_json)
      assert got == expected
    end

    test "does not fail on invalid json" do
      invalid_json = %{"other" => nil}

      expected = %Vehicle{
        block: nil,
        heading: nil,
        latitude: nil,
        longitude: nil,
        speed: nil,
        timestamp: nil,
        trip: nil,
        vehicle_id: nil
      }

      got = Vehicle.from_json(invalid_json)
      assert got == expected
    end

    test "converts lat/long of 0 to nil" do
      json = %{@valid_vehicle_json | "Latitude" => 0, "Longitude" => 0}

      expected = %Vehicle{
        block: "602",
        heading: 48,
        latitude: nil,
        longitude: nil,
        speed: 14,
        timestamp: @valid_timestamp,
        trip: "612",
        vehicle_id: 1827
      }

      got = Vehicle.from_json(json)
      assert got == expected
    end

    test "zero-pads trip/block to 3 characters" do
      json = %{@valid_vehicle_json | "WorkID" => 9, "TripID" => 10}

      expected = %Vehicle{
        block: "009",
        heading: 48,
        latitude: 42.28179,
        longitude: -71.15936,
        speed: 14,
        timestamp: @valid_timestamp,
        trip: "010",
        vehicle_id: 1827
      }

      got = Vehicle.from_json(json)
      assert got == expected
    end

    test "handles a TripID as a string" do
      vehicle = ~J({"Heading":199.0,
        "Latitude":42.23879,
        "Longitude":-71.13356,
        "Source":"AVL",
        "Speed":1,
        "TripID":"745",
        "Update Time":"2022-01-18T16:29:00.000000Z",
        "VehicleID":1823})

      assert %Vehicle{
               heading: 199.0,
               latitude: 42.23879,
               longitude: -71.13356,
               speed: 1,
               timestamp: ~U[2022-01-18 16:29:00Z],
               trip: "745",
               vehicle_id: 1823,
               block: nil
             } == Vehicle.from_json(vehicle)
    end

    test "Turns 000 TripID into :unassigned" do
      vehicle = ~J({"Heading":199.0,
        "Latitude":42.23879,
        "Longitude":-71.13356,
        "Source":"AVL",
        "Speed":1,
        "TripID":"000",
        "Update Time":"2022-01-18T16:29:00.000000Z",
        "VehicleID":1823})

      assert %Vehicle{trip: :unassigned} = Vehicle.from_json(vehicle)
    end

    test "Turns N/A TripID into :unassigned" do
      vehicle = ~J({"Heading":199.0,
        "Latitude":42.23879,
        "Longitude":-71.13356,
        "Source":"AVL",
        "Speed":1,
        "TripID":"N/A",
        "Update Time":"2022-01-18T16:29:00.000000Z",
        "VehicleID":1823})

      assert %Vehicle{trip: :unassigned} = Vehicle.from_json(vehicle)
    end
  end
end
