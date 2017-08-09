defmodule BoardingStatus.ProducerConsumerTest do
  @moduledoc false
  use ExUnit.Case
  import BoardingStatus.ProducerConsumer

  @moduletag :capture_log
  @data "test/fixtures/firebase.json"
  |> File.read!
  |> Poison.decode!

  describe "handle_events/2" do
    test "returns a list of parsed %BoardingStatus{} from %ServerSentEvent{}" do
      results = Map.get(@data, "results")
      event = %ServerSentEvent{data: Poison.encode!(%{data: results})}

      assert {:noreply, [statuses], :state} = handle_events([%ServerSentEvent{}, event], :from, :state)

      refute statuses == []
      for status <- statuses do
        assert %BoardingStatus{} = status
      end
    end

    test "handles the initial value, which is nested differently" do
      event = %ServerSentEvent{data: Poison.encode!(%{data: @data})}
      assert {:noreply, [statuses], :state} = handle_events([event], :from, :state)
      refute statuses == []
    end

    test "ignores invalid JSON" do
      assert {:noreply, [], :state} = handle_events([%ServerSentEvent{}], :from, :state)
    end
  end
end
