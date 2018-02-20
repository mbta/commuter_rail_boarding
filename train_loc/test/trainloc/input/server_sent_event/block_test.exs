defmodule TrainLoc.Input.ServerSentEvent.BlockTest do
  alias TrainLoc.Input.ServerSentEvent.Block
  use ExUnit.Case, async: true
  
  describe "parse/1" do
    test "ok on valid chunk" do
      json_binary = ~s({"1533":{"fix":1,"heading":0,"latitude":4224005,"longitude":-7113007,"routename":"","speed":0,"updatetime":1516338396,"vehicleid":1533,"workid":0})
      event_line = "event: put"
      data_line = "data: #{json_binary}"
      chunk = event_line <> "\n" <> data_line
      expected = {:ok, %Block{event: "put", binary: json_binary <> "\n"}}
      assert Block.parse(chunk) == expected
    end
    test "error on invalid chunk" do
      invalid_chunk = "thing"
      error_reason = %{
        expected: ["put", "message", "keep-alive", "auth_revoked", "cancel"],
        got: "",
        reason: "Unexpected event type",
      }
      expected = {:error, error_reason}
      assert Block.parse(invalid_chunk) == expected
    end
  end

  describe "validate_block/1" do
    @valid_block %Block{event: "put"}
    @invalid_block %Block{event: "invalid_value_here"}
    test "ok with valid event" do
      assert Block.validate_block(@valid_block) == :ok
    end
    test "error with unexpected event" do
      error_map = %{
        expected: ["put", "message", "keep-alive", "auth_revoked", "cancel"],
        got: "invalid_value_here",
        reason: "Unexpected event type",
      }
      assert Block.validate_block(@invalid_block) == {:error, error_map}
    end
  end

  test "to_server_sent_event/1 returns a ServerSentEvent" do
    block = %Block{event: "put", binary: "{}"}
    sse = Block.to_server_sent_event(block)
    assert sse.data == "{}"
    assert sse.event == "put"
  end

end