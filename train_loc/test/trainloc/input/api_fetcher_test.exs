defmodule TrainLoc.Input.APIFetcherTest do

  use ExUnit.Case

  import TrainLoc.Input.APIFetcher

  alias TrainLoc.Input.ServerSentEvent

  @moduletag :capture_log

  describe "start_link/1" do
    test "returns a pid when a URL is provided" do
      assert {:ok, pid} = start_link(url: "http://httpbin.org/get")
      assert is_pid(pid)
    end

    test "raises an error if a URL isn't provided" do
      assert_raise KeyError, fn -> start_link([]) end
    end

    test "does not connect to the URL without a consumer" do
      assert {:ok, _pid} = start_link(url: "http://does-not-exist.test")
    end
  end

  describe "handle_info/2" do
    test "ignores a 200 status" do
      state = %TrainLoc.Input.APIFetcher{}
      assert {:noreply, ^state} = handle_info(%HTTPoison.AsyncStatus{code: 200}, state)
    end

    test "crashes on a non-200 status" do
      state = %TrainLoc.Input.APIFetcher{}
      assert_raise FunctionClauseError, fn ->
        handle_info(%HTTPoison.AsyncStatus{code: 401}, state)
      end
    end

    test "ignores headers" do
      state = %TrainLoc.Input.APIFetcher{}
      assert {:noreply, ^state} = handle_info(%HTTPoison.AsyncHeaders{}, state)
    end

    test "does nothing with a partial chunk" do
      state = %TrainLoc.Input.APIFetcher{}
      assert {:noreply, _state} = handle_info(%HTTPoison.AsyncChunk{chunk: "data:"}, state)
    end

    test "with a full chunk, returns an event" do
      state = %TrainLoc.Input.APIFetcher{send_to: self()}
      assert {:noreply, state} = handle_info(%HTTPoison.AsyncChunk{chunk: "data:"}, state)
      handle_info(%HTTPoison.AsyncChunk{chunk: "data\n\n"}, state)
      assert_receive {:events, [event] = [%ServerSentEvent{}]}
      assert event.data == "data\n"
    end

    test "doesn't crash on unknown call" do
      state = %TrainLoc.Input.APIFetcher{}
      assert {:reply, {:error, "Unknown callback."}, ^state} = handle_call(:unknown_call, self(), state)
    end

    test "doesn't crash on unknown cast" do
      state = %TrainLoc.Input.APIFetcher{}
      assert {:noreply, ^state} = handle_cast(:unknown_cast, state)
    end
  end
end
