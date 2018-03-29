defmodule Busloc.VehicleTest do
  use ExUnit.Case, async: true
  alias Busloc.Vehicle
  import Busloc.Vehicle
  alias Busloc.Utilities.Time, as: BuslocTime

  describe "from_transitmaster_map/2" do
    test "parses a map into a Vehicle struct" do
      map = %{
        block: "A60-36",
        heading: 135,
        latitude: 42.3218438,
        longitude: -71.1777327,
        timestamp: "150646",
        vehicle_id: "0401"
      }

      datetime = Timex.to_datetime(~N[2018-03-26T15:11:05], "America/New_York")

      expected =
        {:ok,
         %Vehicle{
           vehicle_id: "0401",
           block: "A60-36",
           latitude: 42.3218438,
           longitude: -71.1777327,
           heading: 135,
           source: :transitmaster,
           timestamp: BuslocTime.parse_transitmaster_timestamp("150646", datetime)
         }}

      actual = from_transitmaster_map(map, datetime)
      assert expected == actual
    end

    test "returns an error if we're unable to convert the map" do
      assert {:error, _} = from_transitmaster_map(%{}, DateTime.utc_now())
    end
  end

  describe "log_line/1" do
    test "logs all the data from the vehicle" do
      vehicle = %Vehicle{
        vehicle_id: "veh_id",
        block: "50",
        latitude: 1.234,
        longitude: -5.678,
        heading: 29,
        source: :transitmaster,
        timestamp: DateTime.from_naive!(~N[2018-03-28T20:15:12], "Etc/UTC")
      }

      actual = log_line(vehicle)
      assert actual =~ ~s(vehicle_id="veh_id")
      assert actual =~ ~s(block="50")
      assert actual =~ "latitude=1.234"
      assert actual =~ "longitude=-5.678"
      assert actual =~ "heading=29"
      assert actual =~ "source=transitmaster"
      assert actual =~ "timestamp=2018-03-28T20:15:12Z"
    end
  end
end
