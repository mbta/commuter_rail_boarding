defmodule Busloc.TspTest do
  use ExUnit.Case, async: true
  alias Busloc.Tsp
  import Busloc.Tsp

  doctest Busloc.Tsp

  describe "from_tsp_map/1" do
    test "parses a map into a Tsp struct" do
      map = %{
        guid: "78753CE4-58E9-4fb8-96B1-3FD9975A1932",
        traffic_signal_event_id: 101,
        event_type: "TSP_CHECKINMESSAGE",
        event_time: "2011-12-02T15:45:10-05:00",
        event_geo_node: 12345,
        vehicle_id: 1701,
        route_id: 67890,
        approach_direction: 45,
        latitude: 42.0356365,
        longitude: -87.9601951,
        deviation_from_schedule: 30,
        bus_load: 20,
        distance: 54321
      }

      datetime = DateTime.from_naive!(~N[2011-12-02T20:45:10], "Etc/UTC")

      expected =
        {:ok,
         %Tsp{
           guid: "78753CE4-58E9-4fb8-96B1-3FD9975A1932",
           traffic_signal_event_id: 101,
           event_type: "TSP_CHECKINMESSAGE",
           event_time: datetime,
           event_geo_node: 12345,
           vehicle_id: 1701,
           route_id: 67890,
           approach_direction: 45,
           latitude: 42.0356365,
           longitude: -87.9601951,
           deviation_from_schedule: 30,
           bus_load: 20,
           distance: 54321
         }}

      actual = from_tsp_map(map)
      assert expected == actual
    end

    test "returns an error if we're unable to convert the map" do
      assert {:error, _} = from_tsp_map(%{})
    end
  end
end
