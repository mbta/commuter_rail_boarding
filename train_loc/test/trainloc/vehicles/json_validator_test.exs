defmodule TrainLoc.Vehicles.JsonValidatorTest do
  use ExUnit.Case, async: true
  import TrainLoc.Vehicles.JsonValidator
  require TestHelpers

  @valid_json %{
    "fix" => 1,
    "heading" => 0,
    "latitude" => 4_237_405,
    "longitude" => -7_107_496,
    "routename" => "",
    "speed" => 0,
    "updatetime" => 1_516_115_007,
    "vehicleid" => 1633,
    "workid" => 0
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
        |> Map.drop(["fix"])
        |> validate()

      assert result == {:error, :invalid_vehicle_json}
    end

    test "fails with an unexpected value" do
      result =
        @valid_json
        |> Map.put("fix", "other")
        |> validate()

      assert result == {:error, :invalid_vehicle_json}
    end
  end
end
