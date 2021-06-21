defmodule BoardingStatus.ProducerConsumerTest do
  @moduledoc false
  use ExUnit.Case
  import BoardingStatus.ProducerConsumer

  # @moduletag :capture_log
  @data "test/fixtures/firebase.json"
        |> File.read!()
        |> Jason.decode!()
  @state %BoardingStatus.ProducerConsumer{producers: []}

  describe "handle_events/2" do
    test "returns a list of parsed %BoardingStatus{} from %ServerSentEvent{}" do
      results = Map.get(@data, "results")

      event = %ServerSentEventStage.Event{
        event: "put",
        data: Jason.encode!(%{data: results})
      }

      assert {:noreply, [statuses], %BoardingStatus.ProducerConsumer{}} =
               handle_events(
                 [%ServerSentEventStage.Event{}, event],
                 :from,
                 @state
               )

      refute statuses == []

      for status <- statuses do
        assert %BoardingStatus{} = status
      end
    end

    test "handles the secondary value, which is nested differently" do
      event = %ServerSentEventStage.Event{
        event: "put",
        data: Jason.encode!(%{data: @data})
      }

      assert {:noreply, [statuses], %BoardingStatus.ProducerConsumer{}} =
               handle_events([event], :from, @state)

      refute statuses == []
    end

    test "ignores invalid JSON" do
      assert {:noreply, [], %BoardingStatus.ProducerConsumer{}} =
               handle_events([%ServerSentEventStage.Event{}], :from, @state)
    end
  end

  describe "timeouts" do
    test "receives a timeout message if we haven't gotten an event" do
      init(subscribe_to: [], timeout_after: 50)
      assert_receive :timeout
    end

    test "does not receive a timeout after a message" do
      {_, state, _} = init(subscribe_to: [], timeout_after: 50)
      {_, [], state2} = handle_events([], :from, state)
      refute_received :timeout
      assert state2.timeout_ref != state.timeout_ref
    end
  end

  describe "handle_info/2" do
    test ":timeout reschedules the timer" do
      state = %BoardingStatus.ProducerConsumer{producers: []}

      assert {:noreply, [], state2} = handle_info(:timeout, state)
      assert state2.timeout_ref != state.timeout_ref
    end

    test ":timeout refreshes the connection" do
      state = %BoardingStatus.ProducerConsumer{producers: [:x]}

      handle_info(:timeout, state, &__MODULE__.send_self/1)

      assert_received :x
    end
  end

  describe "maybe_refresh!/1" do
    @state %BoardingStatus.ProducerConsumer{
      producers: [:one, :two]
    }
    @refresh_fn &__MODULE__.send_self/1

    test "refreshes when any of the events were `auth_revoked`" do
      events =
        for event <- ~w(put keep-alive auth_revoked) do
          %ServerSentEventStage.Event{event: event}
        end

      maybe_refresh!(events, @state, @refresh_fn)
      assert_received :one
      assert_received :two
    end

    test "does not refreshes when non of the events were `auth_revoked`" do
      events =
        for event <- ~w(put keep-alive) do
          %ServerSentEventStage.Event{event: event}
        end

      maybe_refresh!(events, @state, @refresh_fn)
      refute_received :one
      refute_received :two
    end
  end

  def send_self(message) do
    send(self(), message)
  end
end
