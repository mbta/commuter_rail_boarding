defmodule Uploader.ConsumerTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Uploader.Consumer
  alias TrainLoc.S3

  setup do
    S3.InMemory.start()
    on_exit(fn -> S3.InMemory.stop() end)
  end

  describe "start_link/1" do
    test "starts the upload consumer" do
      assert {:ok, pid} = start_link([])
      assert is_pid(pid)
    end
  end

  describe "handle_events/3" do
    test "uploads the last data received" do
      assert {:noreply, [], :state} =
               handle_events(
                 [{"a", "first"}, {"a", "second"}, {"a", "third"}],
                 :from,
                 :state
               )

      objects = S3.InMemory.list_objects()

      assert Map.has_key?(objects, "console")

      assert Map.fetch!(objects, "console") == %{
               "commuter_rail_boarding/a" => "third",
               "opts" => [acl: :public_read]
             }
    end

    test "uploads the last data received to new bucket" do
      assert {:noreply, [], :state} =
               handle_events(
                 [
                   {"TripUpdates_enhanced.json", "gtfs1"},
                   {"TripUpdates_enhanced.json", "gtfs2"},
                   {"TripUpdates_enhanced.json", "gtfs3"}
                 ],
                 :from,
                 :state
               )

      objects = S3.InMemory.list_objects()

      assert Map.has_key?(objects, "new_bucket")

      assert objects["new_bucket"] == %{
               "TripUpdates_enhanced.json" => "gtfs3",
               "opts" => []
             }
    end
  end
end
