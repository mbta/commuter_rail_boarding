defmodule Busloc.Encoder.NextbusXmlTest do
  use ExUnit.Case, async: true
  alias Busloc.Vehicle
  import Busloc.Encoder.NextbusXml

  describe "vehicle_to_element/1" do
    test "convert a vehicle into NextBus-format XML" do
      vehicle = %Vehicle{
        vehicle_id: "veh_id",
        block: "A50-123",
        latitude: 1.234,
        longitude: -5.678,
        heading: 29,
        source: :transitmaster,
        timestamp: DateTime.from_naive!(~N[2018-03-28T20:15:12], "Etc/UTC")
      }

      actual =
        vehicle
        |> vehicle_to_element
        |> XmlBuilder.generate()

      expected = "<vehicle>
  <id>veh_id</id>
  <date>2018-03-28 20:15:12</date>
  <lat>1.234</lat>
  <lon>-5.678</lon>
  <direction>29</direction>
  <block>A50-123</block>
  <vehstatus>f</vehstatus>
</vehicle>"

      assert expected == actual
    end

    test "convert non-GMT vehicle into NextBus-format XML" do
      vehicle = %Vehicle{
        vehicle_id: "veh_id",
        block: "A50-123",
        latitude: 1.234,
        longitude: -5.678,
        heading: 29,
        source: :transitmaster,
        timestamp: Timex.to_datetime(~N[2018-03-28T20:15:12], "America/New_York")
      }

      actual =
        vehicle
        |> vehicle_to_element
        |> XmlBuilder.generate()

      expected = "<vehicle>
  <id>veh_id</id>
  <date>2018-03-29 00:15:12</date>
  <lat>1.234</lat>
  <lon>-5.678</lon>
  <direction>29</direction>
  <block>A50-123</block>
  <vehstatus>f</vehstatus>
</vehicle>"

      assert expected == actual
    end
  end

  describe "encode/1" do
    test "convert list of vehicles into NextBus-format XML" do
      vehicles = [
        %Vehicle{
          vehicle_id: "0123",
          block: "A50-123",
          latitude: 1.234,
          longitude: -5.678,
          heading: 29,
          source: :transitmaster,
          timestamp: Timex.to_datetime(~N[2018-03-28T20:15:12], "America/New_York")
        },
        %Vehicle{
          vehicle_id: "6070",
          block: "T350-71",
          latitude: 13.234,
          longitude: -57.6789,
          heading: 288,
          source: :transitmaster,
          timestamp: Timex.to_datetime(~N[2018-03-28T20:16:02], "America/New_York")
        }
      ]

      actual = encode(vehicles)

      expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<history>
  <vehicles>
    <vehicle>
      <id>0123</id>
      <date>2018-03-29 00:15:12</date>
      <lat>1.234</lat>
      <lon>-5.678</lon>
      <direction>29</direction>
      <block>A50-123</block>
      <vehstatus>f</vehstatus>
    </vehicle>
    <vehicle>
      <id>6070</id>
      <date>2018-03-29 00:16:02</date>
      <lat>13.234</lat>
      <lon>-57.6789</lon>
      <direction>288</direction>
      <block>T350-71</block>
      <vehstatus>f</vehstatus>
    </vehicle>
  </vehicles>
</history>"

      assert expected == actual
    end
  end
end
