defmodule TrainLoc.Input.ServerSentEventTest do
  use ExUnit.Case
  alias TrainLoc.Input.ServerSentEvent
  import TrainLoc.Input.ServerSentEvent
    
  @first_message_json %{
    "data" => %{
      "processResults" => %{
        "date" => "January 29, 2018 2:23:00 PM",
        "results" => 16,
      },
    "results" => %{
      "0"    => %{"fix" => 0, "heading" => 0, "latitude" => 0, "longitude" => 0, "routename" => " ", "speed" => 0, "updatetime" => 0, "vehicleid" => 0, "workid" => 0},
      "1533" => %{"fix" => 1, "heading" => 0, "latitude" => 4224005, "longitude" => -7113007, "routename" => "", "speed" => 0, "updatetime" => 1516338396, "vehicleid" => 1533, "workid" => 0},
      "1625" => %{"fix" => 1, "heading" => 0, "latitude" => 4237393, "longitude" => -7107462, "routename" => "", "speed" => 0, "updatetime" => 1517235765, "vehicleid" => 1625, "workid" => 0},
      "1626" => %{"fix" => 1, "heading" => 0, "latitude" => 4237433, "longitude" => -7107749, "routename" => "", "speed" => 0, "updatetime" => 1517235765, "vehicleid" => 1626, "workid" => 0},
      "1627" => %{"fix" => 1, "heading" => 279, "latitude" => 4237435, "longitude" => -7107744, "routename" => "9999", "speed" => 0, "updatetime" => 1517235751, "vehicleid" => 1627, "workid" => 0},
      "1628" => %{"fix" => 6, "heading" => 318, "latitude" => 4236698, "longitude" => -7106314, "routename" => "168", "speed" => 0, "updatetime" => 1517235768, "vehicleid" => 1628, "workid" => 402},
      "1629" => %{"fix" => 1, "heading" => 169, "latitude" => 4236763, "longitude" => -7106262, "routename" => "214", "speed" => 0, "updatetime" => 1517235757, "vehicleid" => 1629, "workid" => 300},
      "1630" => %{"fix" => 1, "heading" => 0, "latitude" => 4237415, "longitude" => -7107522, "routename" => "", "speed" => 0, "updatetime" => 1517235767, "vehicleid" => 1630, "workid" => 0},
      "1631" => %{"fix" => 6, "heading" => 318, "latitude" => 4236713, "longitude" => -7106332, "routename" => "324", "speed" => 0, "updatetime" => 1517235509, "vehicleid" => 1631, "workid" => 200},
      "1632" => %{"fix" => 1, "heading" => 281, "latitude" => 4237389, "longitude" => -7107494, "routename" => "9999", "speed" => 0, "updatetime" => 1517235771, "vehicleid" => 1632, "workid" => 0},
      "1633" => %{"fix" => 1, "heading" => 247, "latitude" => 4256256,  "longitude" => -7086808, "routename" => "116", "speed" => 24, "updatetime" => 1517235752, "vehicleid" => 1633, "workid" => 104},
      "1634" => %{"fix" => 1, "heading" => 0, "latitude" => 4237449, "longitude" => -7107984, "routename" => "", "speed" => 0, "updatetime" => 1517199973, "vehicleid" => 1634, "workid" => 0},
      "1635" => %{"fix" => 1, "heading" => 75, "latitude" => 4237544, "longitude" => -7107501, "routename" => "", "speed" => 0, "updatetime" => 1453308912, "vehicleid" => 1635, "workid" => 0},
      "1636" => %{"fix" => 1, "heading" => 331, "latitude" => 4240295, "longitude" => -7111302, "routename" => "321", "speed" => 28, "updatetime" => 1517235775, "vehicleid" => 1636, "workid" => 200},
      "1637" => %{"fix" => 1, "heading" => 123, "latitude" => 4237441, "longitude" => -7107523, "routename" => "9999", "speed" => 0,  "updatetime" => 1517235745, "vehicleid" => 1637, "workid" => 0},
      "4043440397" => %{"fix" => 0, "heading" => 0, "latitude" => 0,  "longitude" => 0, "routename" => " ", "speed" => 0, "updatetime" => 0, "vehicleid" => 4043440397, "workid" => 0}}}, "path" => "/"}

  @tag current: true
  test "from_string/1 can parse vehicles in a \"results\" key" do
    raw_binary = "event: put\ndata: #{Poison.encode!(@first_message_json)}\n\n"
    assert %ServerSentEvent{} = sse = from_string(raw_binary)
    assert sse.json != nil
  end
end