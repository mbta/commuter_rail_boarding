defmodule Busloc.Tsp.SenderTest do
  use ExUnit.Case, async: true
  import Busloc.Tsp.Sender
  import Busloc.Utilities.ConfigHelpers
  alias Busloc.Tsp

  describe "tsp_to_http/1" do
    test "convert a TSP request message into an http URL for the IBI software" do
      tsp = %Tsp{
        guid: "2AE367A6-A785-4445-A7EA-122713E737F2",
        traffic_signal_event_id: 1,
        event_type: "TSP_CHECKINMESSAGE",
        event_time: DateTime.from_naive!(~N[2018-07-10T22:45:08], "Etc/UTC"),
        event_geo_node: 1234,
        vehicle_id: "0709",
        route_id: 749,
        approach_direction: 180,
        latitude: 41.234,
        longitude: -71.678,
        deviation_from_schedule: 30,
        bus_load: 0,
        distance: 100
      }

      actual =
        tsp
        |> tsp_to_http

      assert actual =~ config(Busloc.Tsp.Sender, :tsp_url)
      assert actual =~ "messageid=b"
      assert actual =~ "type=request"
      assert actual =~ "intersection=2089"
      assert actual =~ "approach=1"
      assert actual =~ "vehicle=0709"
      assert actual =~ "t=1531262708"
    end

    @tag :capture_log
    test "handle TSP request with failed lookup of intersection ID" do
      tsp = %Tsp{
        guid: "2AE367A6-A785-4445-A7EA-122713E737F2",
        traffic_signal_event_id: 16_234_623,
        event_type: "TSP_CHECKINMESSAGE",
        event_time: DateTime.from_naive!(~N[2018-07-10T22:45:08], "Etc/UTC"),
        event_geo_node: 1234,
        vehicle_id: "0709",
        route_id: 749,
        approach_direction: 180,
        latitude: 41.234,
        longitude: -71.678,
        deviation_from_schedule: 30,
        bus_load: 0,
        distance: 100
      }

      actual =
        tsp
        |> tsp_to_http

      assert actual == ""
    end

    test "convert a TSP cancel message into an http URL for the IBI software" do
      tsp = %Tsp{
        guid: "2AE367A6-A785-4445-A7EA-122713E737F2",
        traffic_signal_event_id: 1,
        event_type: "TSP_CHECKOUTMESSAGE",
        event_time: DateTime.from_naive!(~N[2018-07-10T22:45:48], "Etc/UTC"),
        event_geo_node: 1234,
        vehicle_id: "0709",
        route_id: 749,
        approach_direction: 180,
        latitude: 41.233,
        longitude: -71.678,
        deviation_from_schedule: 25,
        bus_load: 0,
        distance: 80
      }

      actual =
        tsp
        |> tsp_to_http

      assert actual =~ config(Busloc.Tsp.Sender, :tsp_url)
      assert actual =~ "messageid=b"
      assert actual =~ "type=cancel"
      assert actual =~ "ref=b3"
      assert actual =~ "intersection=2089"
      assert actual =~ "approach=1"
      assert actual =~ "vehicle=0709"
      assert actual =~ "t=1531262748"
    end

    @tag :capture_log
    test "handle TSP cancel with failed lookup of intersection ID" do
      tsp = %Tsp{
        guid: "2AE367A6-A785-4445-A7EA-122713E737F2",
        traffic_signal_event_id: 16_234_623,
        event_type: "TSP_CHECKOUTMESSAGE",
        event_time: DateTime.from_naive!(~N[2018-07-10T22:45:48], "Etc/UTC"),
        event_geo_node: 1234,
        vehicle_id: "0709",
        route_id: 749,
        approach_direction: 180,
        latitude: 41.233,
        longitude: -71.678,
        deviation_from_schedule: 25,
        bus_load: 0,
        distance: 80
      }

      actual =
        tsp
        |> tsp_to_http

      assert actual == ""
    end
  end
end
