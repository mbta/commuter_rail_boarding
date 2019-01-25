defmodule BoardingStatusTest do
  @moduledoc false
  use ExUnit.Case
  import BoardingStatus
  import ExUnit.CaptureLog

  @moduletag :capture_log
  @results "test/fixtures/firebase.json"
           |> File.read!()
           |> Poison.decode!()
           |> Map.get("results")

  setup_all do
    :ok
  end

  describe "from_firebase/1" do
    test "returns {:ok, t} for all items from fixture" do
      refute @results == []

      for result <- Task.async_stream(@results, &from_firebase/1) do
        assert {:ok, {:ok, %BoardingStatus{}}} = result
      end
    end

    test "looks up a stop_sequence" do
      result = List.first(@results)
      assert {:ok, status} = from_firebase(result)
      refute status.stop_sequence == :unknown
    end

    test "predicted_time is scheduled_time without other data" do
      result = List.first(@results)
      assert {:ok, status} = from_firebase(result)

      assert status.scheduled_time ==
               DateTime.from_naive!(~N[2017-11-06T16:15:00], "Etc/UTC")

      assert status.scheduled_time == status.predicted_time
    end

    test "predicted_time comes from gtfsrt_departure if present" do
      result = List.first(@results)
      result = put_in(result["gtfsrt_departure"], "2018-09-01T07:02:03-05:00")
      assert {:ok, status} = from_firebase(result)

      assert status.predicted_time ==
               DateTime.from_naive!(~N[2018-09-01T12:02:03], "Etc/UTC")
    end

    test "predicted_time is :unknown if the status is CANCELLED" do
      result = List.first(@results)

      result =
        Map.merge(result, %{
          "status" => "CX",
          "current_display_status" => "CANCELLED"
        })

      assert {:ok, status} = from_firebase(result)
      assert status.predicted_time == :unknown
    end

    test "creates a trip ID if one doesn't exist" do
      original = List.first(@results)

      result =
        Map.merge(original, %{
          "gtfs_trip_id" => "",
          "gtfs_trip_short_name" => ""
        })

      assert {:ok, status} = from_firebase(result)
      refute status.trip_id == ""
      assert status.route_id == "CR-Fitchburg"
      assert status.stop_sequence == :unknown
      assert status.added?
    end

    test "looks up a trip ID based on the name if needed" do
      original = List.first(@results)
      result = put_in(original["gtfs_trip_id"], "")
      assert from_firebase(result) == from_firebase(original)
    end

    test "logs a warning if we have a non-matched trip short name but no trip ID" do
      original = List.first(@results)

      result =
        Map.merge(original, %{
          "gtfs_trip_id" => "",
          "gtfs_trip_short_name" => "not matching"
        })

      message =
        capture_log(fn ->
          from_firebase(result)
        end)

      assert message =~ "unexpected missing GTFS trip ID"
      assert message =~ "CR-Fitchburg"
      assert message =~ result["gtfs_trip_short_name"]
      assert message =~ result["trip_id"]
    end

    test "logs a warning if there's an error parsing" do
      original = List.first(@results)
      result = Map.put(original, "gtfs_departure_time", "not a time")

      message =
        capture_log(fn ->
          assert from_firebase(result) == :error
        end)

      assert message =~ "unable to parse"
      assert message =~ "{:error, "
      assert message =~ inspect(result)
    end

    test "logs a warning if the map doesn't match" do
      message =
        capture_log(fn ->
          assert from_firebase(%{}) == :error
        end)

      assert message =~ "unable to match"
      assert message =~ "%{}"
    end

    test "ignores items with the wrong movement type" do
      original = List.first(@results)
      result = Map.put(original, "movement_type", "")
      assert from_firebase(result) == :ignore
      result = Map.put(original, "movement_type", "O")
      assert {:ok, _} = from_firebase(result)
    end
  end
end