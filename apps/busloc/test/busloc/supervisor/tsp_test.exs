defmodule Busloc.Supervisor.TspTest do
  use ExUnit.Case

  setup do
    start_supervised!(Busloc.Supervisor.Tsp)
    bypass = Bypass.open()
    Application.put_env(:busloc, Busloc.Tsp.Sender, tsp_url: "http://127.0.0.1:#{bypass.port}/?")
    %{bypass: bypass}
  end

  describe "end_to_end" do
    @tag :capture_log
    test "sending XML to TCP endpoint sends http post to tsp_url", %{bypass: bypass} do
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

      Bypass.expect(bypass, fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)
        assert conn.params["type"] == "cancel"
        Plug.Conn.send_resp(conn, 200, "")
      end)

      {:ok, socket} = :gen_tcp.connect('127.0.0.1', 9006, [:binary, exit_on_close: false])
      :ok = :gen_tcp.send(socket, data)
      :ok = :gen_tcp.shutdown(socket, :write)
      Process.sleep(100)
      assert_receive {:tcp_closed, ^socket}
    end
  end
end
