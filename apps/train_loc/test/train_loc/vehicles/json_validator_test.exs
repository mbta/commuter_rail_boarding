defmodule TrainLoc.Vehicles.JsonValidatorTest do
  use ExUnit.Case, async: true
  import TrainLoc.Vehicles.JsonValidator
  require TestHelpers

  @valid_json %{
    "Heading" => 0,
    "Latitude" => 42.37405,
    "Longitude" => -71.07496,
    "TripID" => 0,
    "Speed" => 0,
    "Update Time" => "2018-01-16T15:03:27Z",
    "VehicleID" => 1633,
    "WorkID" => 0
  }

  describe "validate/1" do
    test "works on a valid json map" do
      assert validate(@valid_json) == :ok
    end

    test "fails with a non-map" do
      assert validate(nil) == {:error, :invalid_json}
    end

    test "fails with a missing key" do
      result =
        @valid_json
        |> Map.drop(["Heading"])
        |> validate()

      assert result == {:error, :invalid_vehicle_json}
    end

    test "fails with an unexpected value" do
      result =
        @valid_json
        |> Map.put("Heading", "other")
        |> validate()

      assert result == {:error, :invalid_vehicle_json}
    end
  end
end
