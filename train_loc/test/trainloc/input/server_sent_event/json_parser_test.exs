defmodule TrainLoc.Input.ServerSentEvent.JsonParserTest do
  use ExUnit.Case, async: true
  import TrainLoc.Input.ServerSentEvent.JsonParser
  require TestHelpers

  test "parse/1" do
    raw_vehicle_json = Poison.encode!(%{
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
      "1632" => %{
        "fix" => 1,
        "heading" => 0,
        "latitude" => 4237405,
        "longitude" => -7107496,
        "routename" => "blep",
        "speed" => 0,
        "updatetime" => 1516115007,
        "vehicleid" => 1632,
        "workid" => 0
      },
    })
    assert {:ok, %{vehicles_json: result, date: nil}} = parse(raw_vehicle_json)
    assert length(result) == 2
    assert TestHelpers.match_any?(%{"vehicleid" => 1633}, result)
    assert TestHelpers.match_any?(%{"vehicleid" => 1632}, result)
  end

  test "extract_vehicles_json/1 can handle a vehicle json map" do
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
    assert extract_vehicles_json(vehicle_json_map) == [%{
      "fix" => 1,
      "heading" => 0,
      "latitude" => 4237405,
      "longitude" => -7107496,
      "routename" => "",
      "speed" => 0,
      "updatetime" => 1516115007,
      "vehicleid" => 1633,
      "workid" => 0
    }]
  end

  test "extract_vehicles_json/1 can handle a vehicle json wrapping map" do
    vehicle_json_map = %{
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
      }
    }
    assert extract_vehicles_json(vehicle_json_map) == [%{
      "fix" => 1,
      "heading" => 0,
      "latitude" => 4237405,
      "longitude" => -7107496,
      "routename" => "",
      "speed" => 0,
      "updatetime" => 1516115007,
      "vehicleid" => 1633,
      "workid" => 0
    }]
  end

  @valid_dated_json %{
    "data" => %{
      "date" => "January 29, 2018 2:23:15 PM", 
    }
  }
  @invalid_dated_json %{
    "data" => %{
      "somthing" => "else",
    }
  }
  test "extract_date/1 finds a date with dated json" do
    assert extract_date(@valid_dated_json) == "January 29, 2018 2:23:15 PM"
  end
  test "extract_date/1 finds a nil with non-dated json" do
    assert extract_date(@invalid_dated_json) == nil
  end
end