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

      expected = %Vehicle{
        vehicle_id: "0401",
        block: "A60-36",
        latitude: 42.3218438,
        longitude: -71.1777327,
        heading: 135,
        source: :transitmaster,
        timestamp: BuslocTime.parse_transitmaster_timestamp("150646", datetime)
      }

      actual = from_transitmaster_map(map, datetime)
      assert expected == actual
    end
  end
end
