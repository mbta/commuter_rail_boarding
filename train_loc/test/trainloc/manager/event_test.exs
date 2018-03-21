defmodule TrainLoc.Manager.EventTest do
  use ExUnit.Case, async: true
  alias TrainLoc.Manager.Event
  require TestHelpers

  test "from_string/1" do
    raw_vehicle_json =
      Poison.encode!(%{
        "1633" => %{
          "fix" => 1,
          "heading" => 0,
          "latitude" => 4_237_405,
          "longitude" => -7_107_496,
          "routename" => "",
          "speed" => 0,
          "updatetime" => 1_516_115_007,
          "vehicleid" => 1633,
          "workid" => 0
        },
        "1632" => %{
          "fix" => 1,
          "heading" => 0,
          "latitude" => 4_237_405,
          "longitude" => -7_107_496,
          "routename" => "blep",
          "speed" => 0,
          "updatetime" => 1_516_115_007,
          "vehicleid" => 1632,
          "workid" => 0
        }
      })

    assert {:ok, %Event{vehicles_json: result, date: nil}} = Event.from_string(raw_vehicle_json)
    assert length(result) == 2
    assert TestHelpers.match_any?(%{"vehicleid" => 1633}, result)
    assert TestHelpers.match_any?(%{"vehicleid" => 1632}, result)
  end
end
