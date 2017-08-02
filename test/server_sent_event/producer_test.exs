defmodule ServerSentEvent.ProducerTest do
  use ExUnit.Case, async: true
  import ServerSentEvent.Producer

  @moduletag :capture_log

  describe "start_link/1" do
    test "returns a pid when a URL is provided" do
      assert {:ok, pid} = start_link(url: "http://httpbin.org/get")
      assert is_pid(pid)
    end

    test "raises an error if a URL isn't provided" do
      assert_raise KeyError, fn -> start_link([]) end
    end
  end

  describe "handle_info/2" do
    test "ignores a 200 status" do
      state = %ServerSentEvent.Producer{}
      assert {:noreply, [], ^state} = handle_info(%HTTPoison.AsyncStatus{code: 200}, state)
    end

    test "crashes on a non-200 status" do
      state = %ServerSentEvent.Producer{}
      assert_raise FunctionClauseError, fn ->
        handle_info(%HTTPoison.AsyncStatus{code: 401}, state)
      end
    end

    test "ignores headers" do
      state = %ServerSentEvent.Producer{}
      assert {:noreply, [], ^state} = handle_info(%HTTPoison.AsyncHeaders{}, state)
    end

    test "does nothing with a partial chunk" do
      state = %ServerSentEvent.Producer{}
      assert {:noreply, [], _state} = handle_info(%HTTPoison.AsyncChunk{chunk: "data:"}, state)
    end

    test "with a full chunk, returns an event" do
      state = %ServerSentEvent.Producer{}
      assert {:noreply, [], state} = handle_info(%HTTPoison.AsyncChunk{chunk: "data:"}, state)
      assert {:noreply, [event], _state} = handle_info(%HTTPoison.AsyncChunk{chunk: "data\n\n"}, state)
      assert event.data == "data\n"
    end
  end
end
