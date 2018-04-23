defmodule TrainLoc.Manager.EventJsonParserTest do
  use ExUnit.Case, async: true
  import TrainLoc.Manager.EventJsonParser
  alias TrainLoc.Manager.Event
  require TestHelpers

  @valid_map %{
    "Heading" => 0,
    "Latitude" => 42.37405,
    "Longitude" => -71.07496,
    "TripID" => 0,
    "Speed" => 0,
    "Update Time" => "2018-01-16T15:03:27Z",
    "VehicleID" => 1633,
    "WorkID" => 0
  }
  @valid_json Poison.encode!(@valid_map)
  @bad_value @valid_map |> Map.put("Heading", "other") |> Poison.encode!()
  @missing_key @valid_map |> Map.drop(["Speed"]) |> Poison.encode!()

  describe "parse/1" do
    test "works on a valid json string" do
      expected_event = %Event{
        date: nil,
        vehicles_json: [@valid_map]
      }

      assert parse(@valid_json) == {:ok, expected_event}
    end

    test "fails with a non-string" do
      assert parse(nil) == {:error, :invalid_json}
    end

    test "fails with a missing key" do
      assert parse(@missing_key) == {:error, :invalid_vehicle_json}
    end

    test "fails with an unexpected value" do
      assert parse(@bad_value) == {:error, :invalid_vehicle_json}
    end
  end

  describe "extract_vehicles_json/1" do
    test "works with a vehicle json map" do
      vehicle_json_map = %{
        "Heading" => 0,
        "Latitude" => 42.37405,
        "Longitude" => -71.07496,
        "TripID" => 0,
        "Speed" => 0,
        "Update Time" => "2018-01-16T15:03:27Z",
        "VehicleID" => 1633,
        "WorkID" => 0
      }

      assert extract_vehicles_json(vehicle_json_map) == [
               %{
                 "Heading" => 0,
                 "Latitude" => 42.37405,
                 "Longitude" => -71.07496,
                 "TripID" => 0,
                 "Speed" => 0,
                 "Update Time" => "2018-01-16T15:03:27Z",
                 "VehicleID" => 1633,
                 "WorkID" => 0
               }
             ]
    end

    test "works with a vehicle json wrapping map" do
      vehicle_json_map = %{
        "1633" => %{
          "Heading" => 0,
          "Latitude" => 42.37405,
          "Longitude" => -71.07496,
          "TripID" => 0,
          "Speed" => 0,
          "Update Time" => "2018-01-16T15:03:27Z",
          "VehicleID" => 1633,
          "WorkID" => 0
        }
      }

      assert extract_vehicles_json(vehicle_json_map) == [
               %{
                 "Heading" => 0,
                 "Latitude" => 42.37405,
                 "Longitude" => -71.07496,
                 "TripID" => 0,
                 "Speed" => 0,
                 "Update Time" => "2018-01-16T15:03:27Z",
                 "VehicleID" => 1633,
                 "WorkID" => 0
               }
             ]
    end
  end

  describe "extract_date/1" do
    test "finds a date with dated json" do
      valid_dated_json = %{
        "data" => %{
          "date" => "January 29, 2018 2:23:15 PM"
        }
      }

      assert extract_date(valid_dated_json) == "January 29, 2018 2:23:15 PM"
    end

    test "extract_date/1 finds a nil with non-dated json" do
      invalid_dated_json = %{
        "data" => %{
          "somthing" => "else"
        }
      }

      assert extract_date(invalid_dated_json) == nil
    end
  end
end
