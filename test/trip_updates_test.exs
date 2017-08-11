defmodule TripUpdatesTest do
  @moduledoc false
  use ExUnit.Case, async: true

  import TripUpdates

  describe "to_map/1" do
    test "returns the version in the header" do
      map = to_map([])
      assert map.header.gtfs_realtime_version == "1.0"
    end

    test "returns a current timestamp in the header" do
      before_dt = utc_now()
      map = to_map([])
      header_dt = DateTime.from_unix!(map.header.timestamp)
      after_dt = utc_now()

      # they can be equal, but header_dt should be between before_dt and
      # after_dt
      refute DateTime.compare(before_dt, header_dt) == :gt
      refute DateTime.compare(after_dt, header_dt) == :lt
    end

    test "returns a list of trip update entities" do
      map = to_map([%BoardingStatus{}, %BoardingStatus{}])
      assert [_] = map.entity
    end
  end

  describe "entity/2" do
    test "groups statuses by their trip_id" do
      statuses = for trip_id <- ["1", "2", "1"] do
        %BoardingStatus{trip_id: trip_id}
      end
      entities = entity(1234, statuses)
      assert [one, two] = entities
      assert [_, _] = one.trip_update.stop_time_update
      assert [_] = two.trip_update.stop_time_update
    end

    test "returns an empty list of there are no statuses" do
      assert entity(1234, []) == []
    end
  end

  describe "trip_update/2" do
    test "returns an empty list if there are no updates" do
      assert trip_update(1234, []) == []
    end

    test "uses the trip_id from the first status and the time for the ID" do
      status = %BoardingStatus{trip_id: "trip_id"}
      assert [update] = trip_update(1234, [status, %BoardingStatus{}])
      assert update.id == "1234_trip_id"
    end

    test "builds a trip_update for the statuses" do
      assert [update] = trip_update(
        1234, [%BoardingStatus{}, %BoardingStatus{}])
      assert %{} = update.trip_update.trip
      assert [%{}, %{}] = update.trip_update.stop_time_update
    end
  end

  describe "trip/1" do
    test "builds trip information from the status" do
      status = %BoardingStatus{
        scheduled_time: DateTime.from_naive!(~N[2017-02-05T05:06:07], "Etc/UTC"),
        route_id: "route",
        trip_id: "trip",
        direction_id: 1
      }
      assert trip(status) == %{
        trip_id: "trip",
        route_id: "route",
        direction_id: 1,
        start_date: ~D[2017-02-05],
        schedule_relationship: "SCHEDULED"
      }
    end

    test "does not include an unknown direction" do
      status = %BoardingStatus{}
      refute :direction_id in Map.keys(trip(status))
    end

    test "schedule_relationship is ADDED if added? is true" do
      status = %BoardingStatus{
        added?: true}
      assert trip(status).schedule_relationship == "ADDED"
    end

    test "schedule_relationship is CANCELED if the status is :cancelled" do
      # yes, the spellings are different
      status = %BoardingStatus{
        status: :cancelled
      }
      assert trip(status).schedule_relationship == "CANCELED"
    end
  end

  describe "stop_time_update/1" do
    test "builds stop time update from the status" do
      status = %BoardingStatus{
        predicted_time: DateTime.from_unix!(12_345),
        stop_id: "stop",
        stop_sequence: 5,
        status: :all_aboard,
        track: "track"
      }
      assert stop_time_update(status) == %{
        stop_id: "stop",
        stop_sequence: 5,
        departure: %{
          time: 12_345
        },
        boarding_status: "ALL_ABOARD",
        platform_id: "track"
      }
    end

    test "does not include stop sequence if it's unknown" do
      status = %BoardingStatus{}
      refute :stop_sequence in Map.keys(stop_time_update(status))
    end

    test "does not include boarding status if it's unknown" do
      status = %BoardingStatus{
        predicted_time: DateTime.from_unix!(0),
        stop_id: "stop",
        track: "track"
      }
      refute :boarding_status in Map.keys(stop_time_update(status))
    end

    test "does not include track if it's empty" do
      status = %BoardingStatus{
        predicted_time: DateTime.from_unix!(0),
        stop_id: "stop",
        status: :late
      }
      refute :platform_id in Map.keys(stop_time_update(status))
    end

    test "does not include a time if there's no predicted time" do
      status = %BoardingStatus{}
      refute :departure in Map.keys(stop_time_update(status))
    end
  end

  defp utc_now do
    # returns a DateTime in UTC, but without the microseconds
    %{DateTime.utc_now | microsecond: {0, 0}}
  end
end
