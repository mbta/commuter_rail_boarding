defmodule TrainLoc.Input.ServerSentEvent.BlockParserTest do
  use ExUnit.Case, async: true
  import TrainLoc.Input.ServerSentEvent.BlockParser
  alias TrainLoc.Input.ServerSentEvent

  test "parse/1" do
    raw_json =
      ~s({"1533":{"fix":1,"heading":0,"latitude":4224005,"longitude":-7113007,"routename":"","speed":0,"updatetime":1516338396,"vehicleid":1533,"workid":0}})

    event_line = "event: put"
    data_line = "data: #{raw_json}"
    chunk = event_line <> "\n" <> data_line
    got = parse(chunk)
    assert got == %ServerSentEvent{data: raw_json <> "\n", event: "put"}
  end

  test "trim_one_space/1" do
    assert trim_one_space(" thing") == "thing"
    assert trim_one_space("thing") == "thing"
    assert trim_one_space("thing  ") == "thing  "
  end

  test "split_on_newlines/1" do
    assert split_on_newlines("1\n2") == ["1", "2"]
    assert split_on_newlines("1\r\n2") == ["1", "2"]
    assert split_on_newlines("1\r2") == ["1", "2"]
    assert split_on_newlines("123") == ["123"]
    assert split_on_newlines("123 456") == ["123 456"]
  end

  describe "parse_lines/1" do
    test "works on event" do
      got =
        "event: put"
        |> split_on_newlines
        |> parse_lines

      assert got == %ServerSentEvent{data: "", event: "put"}
    end

    test "parse_lines/1 works on data" do
      raw_json =
        ~s({"1533":{"fix":1,"heading":0,"latitude":4224005,"longitude":-7113007,"routename":"","speed":0,"updatetime":1516338396,"vehicleid":1533,"workid":0}})

      data_line = "data: #{raw_json}"

      got =
        data_line
        |> split_on_newlines
        |> parse_lines

      assert got == %ServerSentEvent{data: raw_json <> "\n", event: ""}
    end
  end
end
