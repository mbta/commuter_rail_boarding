defmodule TrainLoc.Input.ServerSentEventTest do
  use ExUnit.Case
  alias TrainLoc.Input.ServerSentEvent
  doctest TrainLoc.Input.ServerSentEvent
  import TrainLoc.Input.ServerSentEvent

  @first_message_json %{
    "data" => %{
      "processResults" => %{
        "date" => "January 29, 2018 2:23:00 PM",
        "results" => 16
      },
      "results" => %{
        "0" => %{
          "fix" => 0,
          "heading" => 0,
          "latitude" => 0,
          "longitude" => 0,
          "routename" => " ",
          "speed" => 0,
          "updatetime" => 0,
          "vehicleid" => 0,
          "workid" => 0
        },
        "1533" => %{
          "fix" => 1,
          "heading" => 0,
          "latitude" => 4_224_005,
          "longitude" => -7_113_007,
          "routename" => "",
          "speed" => 0,
          "updatetime" => 1_516_338_396,
          "vehicleid" => 1533,
          "workid" => 0
        },
        "1625" => %{
          "fix" => 1,
          "heading" => 0,
          "latitude" => 4_237_393,
          "longitude" => -7_107_462,
          "routename" => "",
          "speed" => 0,
          "updatetime" => 1_517_235_765,
          "vehicleid" => 1625,
          "workid" => 0
        },
        "1626" => %{
          "fix" => 1,
          "heading" => 0,
          "latitude" => 4_237_433,
          "longitude" => -7_107_749,
          "routename" => "",
          "speed" => 0,
          "updatetime" => 1_517_235_765,
          "vehicleid" => 1626,
          "workid" => 0
        },
        "1627" => %{
          "fix" => 1,
          "heading" => 279,
          "latitude" => 4_237_435,
          "longitude" => -7_107_744,
          "routename" => "9999",
          "speed" => 0,
          "updatetime" => 1_517_235_751,
          "vehicleid" => 1627,
          "workid" => 0
        },
        "1628" => %{
          "fix" => 6,
          "heading" => 318,
          "latitude" => 4_236_698,
          "longitude" => -7_106_314,
          "routename" => "168",
          "speed" => 0,
          "updatetime" => 1_517_235_768,
          "vehicleid" => 1628,
          "workid" => 402
        },
        "1629" => %{
          "fix" => 1,
          "heading" => 169,
          "latitude" => 4_236_763,
          "longitude" => -7_106_262,
          "routename" => "214",
          "speed" => 0,
          "updatetime" => 1_517_235_757,
          "vehicleid" => 1629,
          "workid" => 300
        },
        "1630" => %{
          "fix" => 1,
          "heading" => 0,
          "latitude" => 4_237_415,
          "longitude" => -7_107_522,
          "routename" => "",
          "speed" => 0,
          "updatetime" => 1_517_235_767,
          "vehicleid" => 1630,
          "workid" => 0
        },
        "1631" => %{
          "fix" => 6,
          "heading" => 318,
          "latitude" => 4_236_713,
          "longitude" => -7_106_332,
          "routename" => "324",
          "speed" => 0,
          "updatetime" => 1_517_235_509,
          "vehicleid" => 1631,
          "workid" => 200
        },
        "1632" => %{
          "fix" => 1,
          "heading" => 281,
          "latitude" => 4_237_389,
          "longitude" => -7_107_494,
          "routename" => "9999",
          "speed" => 0,
          "updatetime" => 1_517_235_771,
          "vehicleid" => 1632,
          "workid" => 0
        },
        "1633" => %{
          "fix" => 1,
          "heading" => 247,
          "latitude" => 4_256_256,
          "longitude" => -7_086_808,
          "routename" => "116",
          "speed" => 24,
          "updatetime" => 1_517_235_752,
          "vehicleid" => 1633,
          "workid" => 104
        },
        "1634" => %{
          "fix" => 1,
          "heading" => 0,
          "latitude" => 4_237_449,
          "longitude" => -7_107_984,
          "routename" => "",
          "speed" => 0,
          "updatetime" => 1_517_199_973,
          "vehicleid" => 1634,
          "workid" => 0
        },
        "1635" => %{
          "fix" => 1,
          "heading" => 75,
          "latitude" => 4_237_544,
          "longitude" => -7_107_501,
          "routename" => "",
          "speed" => 0,
          "updatetime" => 1_453_308_912,
          "vehicleid" => 1635,
          "workid" => 0
        },
        "1636" => %{
          "fix" => 1,
          "heading" => 331,
          "latitude" => 4_240_295,
          "longitude" => -7_111_302,
          "routename" => "321",
          "speed" => 28,
          "updatetime" => 1_517_235_775,
          "vehicleid" => 1636,
          "workid" => 200
        },
        "1637" => %{
          "fix" => 1,
          "heading" => 123,
          "latitude" => 4_237_441,
          "longitude" => -7_107_523,
          "routename" => "9999",
          "speed" => 0,
          "updatetime" => 1_517_235_745,
          "vehicleid" => 1637,
          "workid" => 0
        },
        "4043440397" => %{
          "fix" => 0,
          "heading" => 0,
          "latitude" => 0,
          "longitude" => 0,
          "routename" => " ",
          "speed" => 0,
          "updatetime" => 0,
          "vehicleid" => 4_043_440_397,
          "workid" => 0
        }
      }
    },
    "path" => "/"
  }

  test "from_string/1 can parse vehicles in a \"results\" key" do
    binary_data = Poison.encode!(@first_message_json)
    raw_binary = "event: put\ndata: #{binary_data}\n\n"
    assert %ServerSentEvent{} = sse = from_string(raw_binary)
    assert sse.data == binary_data <> "\n"
    assert sse.event == "put"
  end
end
