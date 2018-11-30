defmodule Busloc.Tsp.Sender do
  import Busloc.Utilities.ConfigHelpers

  require Logger

  @intersection_map config(Tsp, :intersection_map)

  # tsp.event_type TSP_CHECKINMESSAGE request
  # tsp.event_type TSP_CHECKOUTMESSAGE cancel
  # tsp.traffic_signal_event_id map to TSP database ID (string, can have letters), approach (1=N, 2=E, 3=S, 4=W)

  def approach_id(:north), do: 1
  def approach_id(:east), do: 2
  def approach_id(:south), do: 3
  def approach_id(:west), do: 4

  @spec tsp_to_http(Busloc.Tsp.t()) :: String.t()
  def tsp_to_http(tsp = %Busloc.Tsp{event_type: "TSP_CHECKINMESSAGE"}) do
    case @intersection_map[tsp.traffic_signal_event_id] do
      nil ->
        Logger.warn("TSP checkin missing signal: #{inspect(tsp.traffic_signal_event_id)}")
        ""

      {intersection, approach} ->
        query = %{
          # messageid hard-coded since the receiving software doesn't use it
          "messageid" => "g1",
          "type" => "request",
          "intersection" => intersection,
          "approach" => approach_id(approach),
          "vehicle" => tsp.vehicle_id,
          "t" => Timex.to_unix(tsp.event_time)
        }

        config(Busloc.Tsp.Sender, :tsp_url) <> URI.encode_query(query)
    end
  end

  def tsp_to_http(tsp = %Busloc.Tsp{event_type: "TSP_CHECKOUTMESSAGE"}) do
    case @intersection_map[tsp.traffic_signal_event_id] do
      nil ->
        Logger.warn("TSP checkout missing signal: #{inspect(tsp.traffic_signal_event_id)}")
        ""

      {intersection, approach} ->
        query = %{
          # messageid and ref hard-coded since the receiving software doesn't use it
          "messageid" => "g2",
          "type" => "cancel",
          "ref" => "g3",
          "intersection" => intersection,
          "approach" => approach_id(approach),
          "vehicle" => tsp.vehicle_id,
          "t" => Timex.to_unix(tsp.event_time)
        }

        config(Busloc.Tsp.Sender, :tsp_url) <> URI.encode_query(query)
    end
  end
end
