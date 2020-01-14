defmodule TrainLoc.Manager.EventTest do
  use ExUnit.Case, async: true
  alias TrainLoc.Manager.Event
  require TestHelpers

  test "from_string/1" do
    raw_vehicle_json =
      Jason.encode!(%{
        "1633" => %{
          "Heading" => 0,
          "Latitude" => 42.37405,
          "Longitude" => -71.07496,
          "TripID" => 0,
          "Speed" => 0,
          "Update Time" => "2018-01-16T15:03:27Z",
          "VehicleID" => 1633,
          "WorkID" => 0
        },
        "1632" => %{
          "Heading" => 0,
          "Latitude" => 42.37405,
          "Longitude" => -71.07496,
          "TripID" => 123,
          "Speed" => 0,
          "Update Time" => "2018-01-16T15:03:27Z",
          "VehicleID" => 1632,
          "WorkID" => 0
        }
      })

    assert {:ok, %Event{vehicles_json: result, date: nil}} =
             Event.from_string(raw_vehicle_json)

    assert length(result) == 2
    assert TestHelpers.match_any?(%{"VehicleID" => 1633}, result)
    assert TestHelpers.match_any?(%{"VehicleID" => 1632}, result)
  end
end
