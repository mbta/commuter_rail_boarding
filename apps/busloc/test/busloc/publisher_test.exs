defmodule Busloc.PublisherTest do
  use ExUnit.Case
  import Busloc.Publisher

  describe "handle_info(:timeout)" do
    setup do
      start_supervised!({Busloc.State, name: Busloc.State})
      :ok
    end

    @tag :capture_log
    test "Publishes data from Busloc.State by default" do
      {:ok, state} = init([])

      assert {:noreply, _state} = handle_info(:timeout, state)
      assert_receive {:upload, <<_::binary>>}
    end

    @tag :capture_log
    test "publishes data from multiple states" do
      start_supervised!({Busloc.State, name: :publisher_test_state})

      {:ok, state} = init(states: [Busloc.State, :publisher_test_state])

      assert {:noreply, state} = handle_info(:timeout, state)
      assert_receive {:upload, <<pre_set::binary>>}

      Busloc.State.set(:publisher_test_state, [
        %Busloc.Vehicle{vehicle_id: "test", timestamp: DateTime.utc_now()}
      ])

      assert {:noreply, _state} = handle_info(:timeout, state)
      assert_receive {:upload, <<post_set::binary>>}

      refute pre_set == post_set
    end
  end
end
