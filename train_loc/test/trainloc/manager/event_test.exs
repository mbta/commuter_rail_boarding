defmodule TrainLoc.Manager.EventTest do
  use ExUnit.Case, async: true
  alias TrainLoc.Manager.Event
  require TestHelpers

  test "from_string/1" do
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
    assert {:ok, %Event{vehicles_json: result, date: nil}} = Event.from_string(raw_vehicle_json)
    assert length(result) == 2
    assert TestHelpers.match_any?(%{"vehicleid" => 1633}, result)
    assert TestHelpers.match_any?(%{"vehicleid" => 1632}, result)
  end

end