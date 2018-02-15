defmodule TrainLoc.Input.ServerSentEvent.VehicleParserTest do
  use ExUnit.Case, async: true
  import TrainLoc.Input.ServerSentEvent.VehicleParser
  alias TrainLoc.Vehicles.{Schema, Vehicle}

  test "parse/1 works with a valid vehicle json map" do
    vehicle_json_map = %{
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
    assert {[%Vehicle{}], []} = parse(vehicle_json_map)
  end

  @tag current: true
  test "parse/1 errors with an invalid vehicle json map" do
    vehicle_json_map = %{
      # "fix" => 1,
      "heading" => 0,
      "latitude" => 4237405,
      "longitude" => -7107496,
      "routename" => "",
      "speed" => 0,
      "updatetime" => 1516115007,
      "vehicleid" => 1633,
      "workid" => 0
    }
    errors = [
      %{
        field: :fix,
        got: nil,
        reason: "can't be blank",
        validations: [:required],
      }
    ]
    assert parse(vehicle_json_map) == {[], errors}
  end


end