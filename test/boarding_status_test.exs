defmodule BoardingStatusTest do
  @moduledoc false
  use ExUnit.Case
  import BoardingStatus

  @moduletag :capture_log
  @results "test/fixtures/firebase.json"
  |> File.read!
  |> Poison.decode!
  |> Map.get("results")


  setup_all do
    :ok
  end

  describe "from_firebase/1" do
    test "returns {:ok, t} or :error for all items from fixture" do
      refute @results == []
      for result <- Task.async_stream(@results, &from_firebase/1) do
        parsed =
          case result do
            {:ok, {:ok, %BoardingStatus{}}} -> :ok
            {:ok, :error} -> :ok
            unknown -> {:unknown, unknown}
          end
        assert parsed == :ok
      end
    end

    test "predicted_time is scheduled_time without other data" do
      result = List.first(@results)
      assert {:ok, status} = from_firebase(result)
      assert status.scheduled_time == DateTime.from_naive!(~N[2017-08-02T20:15:00], "Etc/UTC")
      assert status.scheduled_time == status.predicted_time
    end

    test "predicted_time comes from gtfsrt_departure if present" do
      result = List.first(@results)
      result = put_in result["gtfsrt_departure"], "2018-09-01T07:02:03-05:00"
      assert {:ok, status} = from_firebase(result)
      assert status.predicted_time == DateTime.from_naive!(~N[2018-09-01T12:02:03], "Etc/UTC")
    end
  end
end
