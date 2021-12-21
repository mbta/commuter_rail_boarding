defmodule BoardingStatusTest do
  @moduledoc false
  use ExUnit.Case
  import BoardingStatus
  import ExUnit.CaptureLog

  # To update the `firebase.json` fixture: set CRB_FIREBASE_URL and GCS_CREDENTIAL_JSON in the
  # environment to the values stored in 1Password under "Keolis production Firebase credentials",
  # run `FirebaseUrl.url()` in an IEx shell (`iex -S mix`), and fetch the resulting URL.

  @moduletag :capture_log
  @results "test/fixtures/firebase.json"
           |> File.read!()
           |> Jason.decode!()
           |> Map.get("results")

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
               DateTime.from_naive!(~N[2021-05-13T16:25:00], "Etc/UTC")

      assert status.scheduled_time == status.predicted_time
    end

    test "predicted_time is scheduled_time when the departure is invalid" do
      result = List.first(@results)
      result = put_in(result["gtfsrt_departure"], "invalid")
      assert {:ok, status} = from_firebase(result)

      assert status.scheduled_time ==
               DateTime.from_naive!(~N[2021-05-13T16:25:00], "Etc/UTC")

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
      assert status.route_id == "CR-Providence"
      assert status.stop_sequence == :unknown
      assert status.added?
    end

    test "looks up a trip ID based on the name if needed" do
      original = List.first(@results)
      result = put_in(original["gtfs_trip_id"], "")
      assert from_firebase(result) == from_firebase(original)
    end

    test "assigns a stop ID based on the track number for Back Bay" do
      original = List.first(@results)
      track1 = %{original | "gtfs_stop_name" => "Back Bay", "track" => "1"}
      track5 = %{original | "gtfs_stop_name" => "Back Bay", "track" => "5"}

      assert {:ok, %{stop_id: "NEC-2276"}} = from_firebase(track1)
      assert {:ok, %{stop_id: "WML-0012"}} = from_firebase(track5)
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
      assert message =~ "CR-Providence"
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

    test "ignores items with is_Stopping False" do
      result = %{
        "current_display_status" => "",
        "direction" => "1",
        "gtfs_departure_time" => "",
        "gtfs_route_id" => "CR-Franklin",
        "gtfs_route_long_name" => "Franklin Line/Foxboro Pilot",
        "gtfs_stop_name" => "Back Bay",
        "gtfs_trip_id" => "CR-Weekday-Fall-19-746",
        "gtfs_trip_short_name" => "746",
        "gtfsrt_departure" => "",
        "headsign" => "",
        "is_Stopping" => "False",
        "movementtype" => "",
        "schedule_id" => "110075",
        "status" => "",
        "track" => "",
        "trip_id" => "436059",
        "trip_stop_id" => "7153739"
      }

      assert :ignore = from_firebase(result)

      result =
        result
        |> Map.delete("is_Stopping")
        |> Map.put("is_stopping", "False")

      assert :ignore = from_firebase(result)
    end

    test "ignores items with bad status" do
      original = List.first(@results)
      result = Map.put(original, "status", "BS")
      assert :ignore = from_firebase(result)
      result = Map.put(original, "status", "GL")
      assert :ignore = from_firebase(result)
      result = Map.put(original, "status", "BL")
      assert :ignore = from_firebase(result)
    end

    test "ignores the Downeaster" do
      original = List.first(@results)
      result = %{original | "gtfs_route_id" => "ADE"}
      assert :ignore = from_firebase(result)
    end
  end
end
