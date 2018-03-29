defmodule Busloc.XmlParserTest do
  use ExUnit.Case, async: true
  import Busloc.XmlParser

  describe "parse_transitmaster_xml/1" do
    test "can parse sample output from a file" do
      data = File.read!("test/data/transitmaster.xml")
      {:ok, parsed} = parse_transitmaster_xml(data)
      assert [_ | _] = parsed

      for map <- parsed do
        assert %{vehicle_id: _} = map
      end
    end

    test "can parse output from the new Transitmaster" do
      data = File.read!("test/data/transitmaster_new.xml")
      {:ok, parsed} = parse_transitmaster_xml(data)
      assert [_ | _] = parsed

      for map <- parsed do
        assert %{vehicle_id: _} = map
      end
    end

    @tag :capture_log
    test "does not include missing fields" do
      xml = ~s(<?xml version="1.0" encoding="utf-8"?>
<ArrayOfVehicle xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://TransitMaster/TransitDataInterfaces/">
  <Vehicle/>
  <Vehicle>
    <ExtensionData />
    <assignmentInformation>
      <ExtensionData />
      <blockId>S746-72</blockId>
      <overloadId>0</overloadId>
      <overloadOffset>0</overloadOffset>
      <scheduledPullout>55620</scheduledPullout>
      <serviceDate>20180322</serviceDate>
    </assignmentInformation>
    <locationDataArray>
      <LocationDataElement>
        <ExtensionData />
        <FOM>9</FOM>
        <adherence>20</adherence>
        <heading>225</heading>
        <lat>42.3317377</lat>
        <layover>false</layover>
        <lon>-71.0650449</lon>
        <odometer>42</odometer>
        <passengerLoad>0</passengerLoad>
        <patternId />
        <revenue>false</revenue>
        <routeId />
        <runId />
        <startTime>55620</startTime>
        <time>150659</time>
        <timepoint />
        <trip>0</trip>
      </LocationDataElement>
    </locationDataArray>
    <vehicleId>1101</vehicleId>
  </Vehicle>
</ArrayOfVehicle>)

      assert {:ok, [_]} = parse_transitmaster_xml(xml)
    end

    test "returns an error when parsing invalid XML" do
      data = "asdf'p;sdiourf;apodsfj;lsdfnhasdjnvsfg"
      assert {:error, :invalid_xml} = parse_transitmaster_xml(data)
    end
  end
end
