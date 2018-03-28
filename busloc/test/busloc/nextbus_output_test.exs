defmodule Busloc.NextbusOutputTest do
  use ExUnit.Case, async: true
  alias Busloc.Vehicle
  import Busloc.NextbusOutput

  describe "create_nextbus_xml_file/1" do
    test "write out Nextbus XML" do
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

      create_nextbus_xml_file(vehicles)

      assert File.exists?("nextbus.xml")
    end
  end

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
        vehicle |> vehicle_to_element
        |> XmlBuilder.generate()

      expected = "<vehicle>
\t<id>veh_id</id>
\t<date>2018-03-28 20:15:12</date>
\t<lat>1.234</lat>
\t<lon>-5.678</lon>
\t<direction>29</direction>
\t<block>A50-123</block>
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
        vehicle |> vehicle_to_element
        |> XmlBuilder.generate()

      expected = "<vehicle>
\t<id>veh_id</id>
\t<date>2018-03-29 00:15:12</date>
\t<lat>1.234</lat>
\t<lon>-5.678</lon>
\t<direction>29</direction>
\t<block>A50-123</block>
</vehicle>"

      assert expected == actual
    end
  end

  describe "to_nextbus_xml/1" do
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

      actual = to_nextbus_xml(vehicles)

      expected = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<history>
\t<vehicles>
\t\t<vehicle>
\t\t\t<id>0123</id>
\t\t\t<date>2018-03-29 00:15:12</date>
\t\t\t<lat>1.234</lat>
\t\t\t<lon>-5.678</lon>
\t\t\t<direction>29</direction>
\t\t\t<block>A50-123</block>
\t\t</vehicle>
\t\t<vehicle>
\t\t\t<id>6070</id>
\t\t\t<date>2018-03-29 00:16:02</date>
\t\t\t<lat>13.234</lat>
\t\t\t<lon>-57.6789</lon>
\t\t\t<direction>288</direction>
\t\t\t<block>T350-71</block>
\t\t</vehicle>
\t</vehicles>
</history>"

      assert expected == actual
    end
  end
end
