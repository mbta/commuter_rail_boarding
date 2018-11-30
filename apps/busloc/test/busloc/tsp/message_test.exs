defmodule Busloc.Tsp.MessageTest do
  use ExUnit.Case, async: true
  import Busloc.Tsp.Message
  import Busloc.Utilities.ConfigHelpers

  describe "data_to_urls/2" do
    setup do
      {:ok, state} = init("socket1")
      %{state: state}
    end

    test "pass incoming socket data to tsp_to_http", %{state: state} do
      data = ~s(TMTSPDATAHEADER000684<?xml version=\"1.0\"?>\r
<TSP_CHECKOUTMESSAGE>\r
<GUID>00FCE914-739B-4981-9651-CA5480C8D4C3</GUID>\r
<TRAFFIC_SIGNAL_EVENT_ID>1</TRAFFIC_SIGNAL_EVENT_ID>\r
<EVENT_TIME>2018-10-12T20:59:31.000Z</EVENT_TIME>\r
<EVENT_GEO_NODE_ABBR>CamGorWB</EVENT_GEO_NODE_ABBR>\r
<VEHICLE_ID>0002</VEHICLE_ID>\r
<ROUTE_ABBR>Unknown</ROUTE_ABBR>\r
<APPROACH_DIRECTION>235</APPROACH_DIRECTION>\r
<NODE_LATITUDE>42.3526278</NODE_LATITUDE>\r
<NODE_LONGITUDE>-71.1401139</NODE_LONGITUDE>\r
<VEHICLE_LATITUDE>42.3407551</VEHICLE_LATITUDE>\r
<VEHICLE_LONGITUDE>-71.0637025</VEHICLE_LONGITUDE>\r
<DEVIATION_FROM_SCHEDULE>0</DEVIATION_FROM_SCHEDULE>\r
<DISTANCE>305</DISTANCE>\r
<BUS_LOAD>0</BUS_LOAD>\r
</TSP_CHECKOUTMESSAGE>\r
)

      assert {[url], ^state} = data_to_urls(data, state)

      assert url =~ config(Busloc.Tsp.Sender, :tsp_url)
      assert url =~ "messageid=g2"
      assert url =~ "type=cancel"
      assert url =~ "intersection=2089"
      assert url =~ "approach=1"
      assert url =~ "vehicle=0002"
      assert url =~ "t=1539377971"
    end

    test "pass socket data in two pieces to tsp_to_http", %{state: state} do
      data1 = ~s(TMTSPDATAHEADER000682<?xml version=\"1.0\"?>\r
<TSP_CHECKOUTMESSAGE>\r
<GUID>00FCE914-739B-4981-9651-CA5480C8D4C3</GUID>\r
<TRAFFIC_SIGNAL_EVENT_ID>1</TRAFFIC_SIGNAL_EVENT_ID>\r
<EVENT_TIME>2018-10-12T20:59:31.000Z</EVENT_TIME>\r
<EVENT_GEO_NODE_ABBR>CamGorWB</EVENT_GEO_NODE_ABBR>\r
<VEHICLE_ID>000)

      data2 = ~s(2</VEHICLE_ID>\r
<ROUTE_ABBR>Unknown</ROUTE_ABBR>\r
<APPROACH_DIRECTION>235</APPROACH_DIRECTION>\r
<NODE_LATITUDE>42.3526278</NODE_LATITUDE>\r
<NODE_LONGITUDE>-71.1401139</NODE_LONGITUDE>\r
<VEHICLE_LATITUDE>42.3407551</VEHICLE_LATITUDE>\r
<VEHICLE_LONGITUDE>-71.0637025</VEHICLE_LONGITUDE>\r
<DEVIATION_FROM_SCHEDULE>0</DEVIATION_FROM_SCHEDULE>\r
<DISTANCE>305</DISTANCE>\r
<BUS_LOAD>0</BUS_LOAD>\r
</TSP_CHECKOUTMESSAGE>\r
)

      assert {[], state} = data_to_urls(data1, state)
      assert {[url], _state} = data_to_urls(data2, state)

      assert url =~ config(Busloc.Tsp.Sender, :tsp_url)
      assert url =~ "vehicle=0002"
    end

    test "pass two messages concatenated together to data_to_urls", %{state: state} do
      data = ~s(TMTSPDATAHEADER000682<?xml version=\"1.0\"?>\r
<TSP_CHECKINMESSAGE>\r
<GUID>00FCE914-739B-4981-9651-CA5480C8D4C3</GUID>\r
<TRAFFIC_SIGNAL_EVENT_ID>1</TRAFFIC_SIGNAL_EVENT_ID>\r
<EVENT_TIME>2018-10-12T20:59:31.000Z</EVENT_TIME>\r
<EVENT_GEO_NODE_ABBR>CamGorWB</EVENT_GEO_NODE_ABBR>\r
<VEHICLE_ID>0002</VEHICLE_ID>\r
<ROUTE_ABBR>Unknown</ROUTE_ABBR>\r
<APPROACH_DIRECTION>235</APPROACH_DIRECTION>\r
<NODE_LATITUDE>42.3526278</NODE_LATITUDE>\r
<NODE_LONGITUDE>-71.1401139</NODE_LONGITUDE>\r
<VEHICLE_LATITUDE>42.3407551</VEHICLE_LATITUDE>\r
<VEHICLE_LONGITUDE>-71.0637025</VEHICLE_LONGITUDE>\r
<DEVIATION_FROM_SCHEDULE>0</DEVIATION_FROM_SCHEDULE>\r
<DISTANCE>305</DISTANCE>\r
<BUS_LOAD>0</BUS_LOAD>\r
</TSP_CHECKINMESSAGE>\r
TMTSPDATAHEADER000684<?xml version=\"1.0\"?>\r
<TSP_CHECKOUTMESSAGE>\r
<GUID>00FCE914-739B-4981-9651-CA5480C8D4C4</GUID>\r
<TRAFFIC_SIGNAL_EVENT_ID>1</TRAFFIC_SIGNAL_EVENT_ID>\r
<EVENT_TIME>2018-10-12T20:59:31.000Z</EVENT_TIME>\r
<EVENT_GEO_NODE_ABBR>CamGorWB</EVENT_GEO_NODE_ABBR>\r
<VEHICLE_ID>0002</VEHICLE_ID>\r
<ROUTE_ABBR>Unknown</ROUTE_ABBR>\r
<APPROACH_DIRECTION>235</APPROACH_DIRECTION>\r
<NODE_LATITUDE>42.3526278</NODE_LATITUDE>\r
<NODE_LONGITUDE>-71.1401139</NODE_LONGITUDE>\r
<VEHICLE_LATITUDE>42.3407551</VEHICLE_LATITUDE>\r
<VEHICLE_LONGITUDE>-71.0637025</VEHICLE_LONGITUDE>\r
<DEVIATION_FROM_SCHEDULE>0</DEVIATION_FROM_SCHEDULE>\r
<DISTANCE>305</DISTANCE>\r
<BUS_LOAD>0</BUS_LOAD>\r
</TSP_CHECKOUTMESSAGE>\r
)

      assert {[url1, url2], ^state} = data_to_urls(data, state)

      assert url1 =~ config(Busloc.Tsp.Sender, :tsp_url)
      assert url1 =~ "messageid=g1"
      assert url1 =~ "type=request"

      assert url2 =~ config(Busloc.Tsp.Sender, :tsp_url)
      assert url2 =~ "messageid=g2"
      assert url2 =~ "type=cancel"
    end
  end
end
