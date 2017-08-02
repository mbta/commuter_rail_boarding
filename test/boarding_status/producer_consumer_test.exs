defmodule BoardingStatus.ProducerConsumerTest do
  @moduledoc false
  use ExUnit.Case
  import BoardingStatus.ProducerConsumer

  @moduletag :capture_log

  setup_all do
    Application.ensure_all_started(:httpoison)
    {:ok, _pid} = TripCache.start_link()
    :ok
  end

  describe "handle_events/2" do
    test "returns a list of parsed %BoardingStatus{} from %ServerSentEvent{}" do
      results = "test/fixtures/firebase.json"
      |> File.read!
      |> Poison.decode!
      |> Map.get("results")
      event = %ServerSentEvent{data: Poison.encode!(%{data: results})}

      assert {:noreply, [statuses], :state} = handle_events([%ServerSentEvent{}, event], :from, :state)

      refute statuses == []
      for status <- statuses do
        assert %BoardingStatus{} = status
      end
    end

    test "ignores invalid JSON" do
      assert {:noreply, [], :state} = handle_events([%ServerSentEvent{}], :from, :state)
    end
  end
end
