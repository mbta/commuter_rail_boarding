defmodule TrainLoc.Input.APIFetcherTest do

  use ExUnit.Case

  import TrainLoc.Input.APIFetcher
  import ExUnit.CaptureLog

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
      chunk = "event: put\ndata: {}"
      state = %TrainLoc.Input.APIFetcher{send_to: self()}
      assert {:noreply, state} = handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state)
      handle_info(%HTTPoison.AsyncChunk{chunk: "\n\n"}, state)
      assert_receive {:events, [event] = [%ServerSentEvent{}]}
      assert event.data == %{}
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

  test "log empty events error" do
    url = "some_url"
    state = %TrainLoc.Input.APIFetcher{url: url}

    fun = fn -> log_empty_events_error(state) end

    expected_log_error =
      "Keolis API Failure - url=#{inspect url} error_type=\"No events parsed\""
    assert capture_log(fun) =~ expected_log_error
  end

  test "log parsing errors" do
    url = "some_url"
    state = %TrainLoc.Input.APIFetcher{url: url}
    errors = [%{content: "some event", reason: "Unexpected event"}]
    fun = fn -> log_parsing_errors(state, errors) end
    captured = capture_log(fun)

    assert captured =~ "Keolis API Failure -"
    assert captured =~ " url=#{inspect url}"
    assert captured =~ " error_type=\"Parsing Error\""
    assert captured =~ " content=\"some event\""
    assert captured =~ " reason=\"Unexpected event\""

  end

  describe "send_events_for_processing/2" do
    test "logs length of events" do
      state = %TrainLoc.Input.APIFetcher{}
      captured = capture_log(fn ->
        send_events_for_processing(state, [])
      end)
      assert captured =~ "received 0 events"
    end

    test "logs each of the events" do
      state = %TrainLoc.Input.APIFetcher{}
      events = [
        %TrainLoc.Input.ServerSentEvent{
          event: "put",
          data: %{"stuff" => true}
        }
      ]
      captured = capture_log(fn ->
        send_events_for_processing(state, events)
      end)
      assert captured =~ ~s(%TrainLoc.Input.ServerSentEvent{)
      assert captured =~ ~s(data: %{"stuff" => true})
      assert captured =~ ~s(event: "put")
    end

  end
  describe "log_keolis_error/1" do
    test "can handle a map" do
      state = %TrainLoc.Input.APIFetcher{url: "the_url"}
      
      payload = %{field1: "value1"}
      captured = capture_log(fn -> log_keolis_error(state, payload) end)
      assert captured =~ ~s(field1="value1")
      assert captured =~ "Keolis API Failure - "
      assert captured =~ ~s(url="the_url")
    end
    test "can handle a string" do
      state = %TrainLoc.Input.APIFetcher{url: "the_url"}      
      payload = "Some Payload"
      captured = capture_log(fn -> log_keolis_error(state, payload) end)
      assert captured =~ ~s(Some Payload)
      assert captured =~ "Keolis API Failure - "
      assert captured =~ ~s(url="the_url")
    end
  end

end
