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
      pid = Process.whereis(TrainLoc.Input.APIFetcher)
      ref = Process.monitor(pid)
      send(pid, %HTTPoison.AsyncStatus{code: 401})
      assert_receive {:DOWN, ^ref, :process, _, :shutdown}
    end

    test "logs error on a non-200 status" do
      state = %TrainLoc.Input.APIFetcher{url: "expected_url"}
      fun = fn -> handle_info(%HTTPoison.AsyncStatus{code: 500}, state) end

      expected_logger_message =
        "Keolis API Failure - " <> "url=\"#{state.url}\" " <> "error_type=\"HTTP status 500\""

      assert capture_log(fun) =~ expected_logger_message
    end

    test "logs error with %HTTPoison.Error{}" do
      state = %TrainLoc.Input.APIFetcher{url: "expected_url"}
      reason = "some reson"
      fun = fn -> handle_info(%HTTPoison.Error{reason: reason}, state) end

      expected_logger_message =
        "Keolis API Failure - " <>
          "url=\"#{state.url}\" " <> "error_type=\"HTTPoison.Error #{reason}\""

      assert capture_log(fun) =~ expected_logger_message
    end

    test "logs error with %HTTPoison.AsyncEnd{}" do
      state = %TrainLoc.Input.APIFetcher{url: "expected_url"}
      fun = fn -> handle_info(%HTTPoison.AsyncEnd{}, state) end
      expected_logger_message = "Keolis API Disconnected. Retrying..."
      assert capture_log(fun) =~ expected_logger_message
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
      json_binary =
        ~s({"1533":{"fix":1,"heading":0,"latitude":4224005,"longitude":-7113007,"routename":"","speed":0,"updatetime":1516338396,"vehicleid":1533,"workid":0})

      event_line = "event: put"
      data_line = "data: #{json_binary}"
      chunk = event_line <> "\n" <> data_line
      state = %TrainLoc.Input.APIFetcher{send_to: self()}

      assert {:noreply, state} = handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state)
      handle_info(%HTTPoison.AsyncChunk{chunk: "\n\n"}, state)
      assert_receive {:events, [event = %ServerSentEvent{}]}
      assert event.data == json_binary <> "\n"
    end

    test "doesn't crash on unknown call" do
      state = %TrainLoc.Input.APIFetcher{}

      assert {:reply, {:error, "Unknown callback."}, ^state} =
               handle_call(:unknown_call, self(), state)
    end

    test "doesn't crash on unknown cast" do
      state = %TrainLoc.Input.APIFetcher{}
      assert {:noreply, ^state} = handle_cast(:unknown_cast, state)
    end
  end

  test "log empty events error" do
    fun = fn -> log_empty_events_error() end
    captured = capture_log(fun)
    assert captured =~ "Keolis API Failure - "
    assert captured =~ "error_type=\"No events parsed\""
  end

  test "log parsing errors" do
    errors = [%{content: "some event", reason: "Unexpected event"}]
    fun = fn -> log_parsing_error(errors) end
    captured = capture_log(fun)

    assert captured =~ "Keolis API Failure -"
    assert captured =~ " error_type=\"Parsing Error\""
    assert captured =~ " content=\"some event\""
    assert captured =~ " reason=\"Unexpected event\""
  end

  describe "send_events_for_processing/2" do
    test "logs length of events when empty" do
      state = %TrainLoc.Input.APIFetcher{}

      captured =
        capture_log(fn ->
          send_events_for_processing([], state.send_to)
        end)

      assert captured =~ "received 0 events"
    end

    test "logs length of events when not empty" do
      state = %TrainLoc.Input.APIFetcher{}

      events = [
        %TrainLoc.Input.ServerSentEvent{
          event: "put"
        }
      ]

      captured =
        capture_log(fn ->
          send_events_for_processing(events, state.send_to)
        end)

      assert captured =~ "received 1 events"
    end

    test "logs each of the events" do
      state = %TrainLoc.Input.APIFetcher{}

      events = [
        %TrainLoc.Input.ServerSentEvent{
          event: "put"
        }
      ]

      captured =
        capture_log(fn ->
          send_events_for_processing(events, state.send_to)
        end)

      assert captured =~ ~s(%TrainLoc.Input.ServerSentEvent{)
      # assert captured =~ ~s(data: %{"stuff" => true})
      assert captured =~ ~s(event: "put")
    end
  end

  describe "log_keolis_error/1" do
    test "can handle a map" do
      payload = %{field1: "value1"}
      captured = capture_log(fn -> log_keolis_error(payload) end)
      assert captured =~ "Keolis API Failure - "
      assert captured =~ ~s(field1="value1")
    end

    test "can handle a string" do
      payload = "Some Payload"
      captured = capture_log(fn -> log_keolis_error(payload) end)
      assert captured =~ "Keolis API Failure - "
      assert captured =~ ~s(error_type="Some Payload")
    end
  end

  describe "extract_event_blocks_from_buffer/1" do
    test "returns the same buffer and no events when no double newlines are present" do
      buffer = "this some content in the buffer"
      assert {[], buffer} == extract_event_blocks_from_buffer(buffer)
    end

    test "splits buffer event binaries and remaining buffer" do
      buffer = """
      event: put
      data: datum_one

      event: put
      data: datum_two

      event: incomplete_event_here
      """

      {event_binaries, new_buffer} = extract_event_blocks_from_buffer(buffer)
      first = "event: put\ndata: datum_one"
      second = "event: put\ndata: datum_two"
      remaining = "event: incomplete_event_here\n"

      assert event_binaries == [first, second]
      assert new_buffer == remaining
    end
  end
end
