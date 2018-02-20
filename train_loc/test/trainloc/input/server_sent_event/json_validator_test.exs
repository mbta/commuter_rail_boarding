defmodule TrainLoc.Input.ServerSentEvent.JsonValidatorTest do
  use ExUnit.Case, async: true
  import TrainLoc.Input.ServerSentEvent.JsonValidator
  require TestHelpers

  @valid_json %{
    "fix" => 1,
    "heading" => 0,
    "latitude" => 4237405,
    "longitude" => -7107496,
    "routename" => "",
    "speed" => 0,
    "updatetime" => 1516115007,
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
      assert result == {:error, "JSON key 'fix' was missing."}
    end

    test "fails with an unexpected value" do
      result =
        @valid_json
        |> Map.put("fix", "other")
        |> validate()
      assert result == {:error, "JSON key 'fix' must be an integer."}
    end
  end

end