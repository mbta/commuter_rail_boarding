defmodule TripCacheTest do
  @moduledoc false
  use ExUnit.Case

  import TripCache

  describe "route_direction_id/1" do
    @route_1_trip_id "34543891"
    test "returns {:ok, route_id, direction_id} for a valid trip" do
      assert {:ok, "1", 0} = route_direction_id(@route_1_trip_id)
    end

    test "a valid trip is cached" do
      assert {first_time, {:ok, "1", 0}} = :timer.tc(fn -> \
        route_direction_id(@route_1_trip_id)
      end)
      assert {second_time, {:ok, "1", 0}} = :timer.tc(fn ->
        route_direction_id(@route_1_trip_id)
      end)
      assert second_time < first_time
    end

    test "returns :error for an invalid trip" do
      assert :error = route_direction_id("made up trip")
    end
  end

  describe "route_trip_name_to_id/2" do
    @route_id "CR-Lowell"
    @trip_name "392"
    @trip_id "CR-Weekday-Spring-17-392"
    @direction_id 1

    test "returns {:ok, trip_id, direction_id} for a value route + name" do
      assert {:ok, @trip_id, @direction_id} ==
        route_trip_name_to_id(@route_id, @trip_name)
    end

    test "caches the result" do
      assert {first_time, _} = :timer.tc(fn -> \
        route_trip_name_to_id(@route_id, @trip_name)
      end)
      assert {second_time, _} = :timer.tc(fn ->
        route_direction_id(@route_1_trip_id)
      end)
      assert second_time < first_time
    end

    test "returns an error if we can't match the name" do
      assert :error == route_trip_name_to_id(@route_id, "not a trip")
    end
  end

  describe "handle_info(:timeout)" do
    test "clears the table and reschedules for the next day" do
      timeout = :timer.seconds(DateHelpers.seconds_until_next_service_date)
      assert {:noreply, :state, ^timeout} = handle_info(:timeout, :state)
      assert :ets.info(TripCache.Table, :size) == 0
    end
  end
end
