defmodule Uploader.ConsumerTest do
  @moduledoc false
  use ExUnit.Case, async: true

  import Uploader.Consumer

  describe "start_link/0" do
    test "starts the upload consumer" do
      assert {:ok, pid} = start_link()
      assert is_pid(pid)
    end
  end

  describe "handle_events/3" do
    test "uploads the last data received" do
      assert {:noreply, [], :state} =
        handle_events(["first", "second", "third"], :from, :state)
      assert_received {:upload, "third"}
    end
  end
end
