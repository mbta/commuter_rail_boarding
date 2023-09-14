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
               "a" => "third",
               "opts" => [acl: :public_read]
             }
    end

    test "uploads the last data received to second bucket if configured" do
      new_bucket_upload? = Application.get_env(:shared, :new_bucket_upload?)
      Application.put_env(:shared, :new_bucket_upload?, true)

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

      Application.put_env(:shared, :new_bucket_upload?, new_bucket_upload?)
    end

    test "doesn't upload data to second bucket if not configured" do
      new_bucket_upload? = Application.get_env(:shared, :new_bucket_upload?)
      Application.put_env(:shared, :new_bucket_upload?, false)

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

      refute Map.has_key?(objects, "new_bucket")
      Application.put_env(:shared, :new_bucket_upload?, new_bucket_upload?)
    end
  end
end
