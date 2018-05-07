defmodule Busloc.PublisherTest do
  use ExUnit.Case
  import Busloc.Publisher

  describe "handle_info(:timeout)" do
    setup do
      start_supervised!({Busloc.State, name: Busloc.State})
      {:ok, state} = init(nil)
      %{state: state}
    end

    @tag :capture_log
    test "Publishes data from Busloc.State", %{state: state} do
      assert {:noreply, _state} = handle_info(:timeout, state)
      assert_receive {:upload, <<_::binary>>}
    end
  end
end
