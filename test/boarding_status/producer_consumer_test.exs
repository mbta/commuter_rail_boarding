defmodule BoardingStatus.ProducerConsumerTest do
  @moduledoc false
  use ExUnit.Case
  import BoardingStatus.ProducerConsumer

  @moduletag :capture_log
  @data "test/fixtures/firebase.json"
        |> File.read!()
        |> Poison.decode!()
  @state %{producers: []}

  describe "handle_events/2" do
    test "returns a list of parsed %BoardingStatus{} from %ServerSentEvent{}" do
      results = Map.get(@data, "results")

      event = %ServerSentEventStage.Event{
        event: "put",
        data: Poison.encode!(%{data: results})
      }

      assert {:noreply, [statuses], @state} =
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
        data: Poison.encode!(%{data: @data})
      }

      assert {:noreply, [statuses], @state} =
               handle_events([event], :from, @state)

      refute statuses == []
    end

    test "ignores invalid JSON" do
      assert {:noreply, [], @state} =
               handle_events([%ServerSentEventStage.Event{}], :from, @state)
    end
  end

  describe "maybe_refresh!/1" do
    @state %{
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
