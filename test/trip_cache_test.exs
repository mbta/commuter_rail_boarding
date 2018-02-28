defmodule TripCacheTest do
  @moduledoc false
  use ExUnit.Case

  import TripCache

  @route_id "CR-Lowell"
  @trip_name "348"
  @trip_id "CR-Weekday-Fall-17-348"
  @direction_id 1

  describe "route_direction_id/1" do
    @route_1_trip_id "35795189"
    test "returns {:ok, route_id, direction_id} for a valid trip" do
      assert {:ok, "1", 0} = route_direction_id(@route_1_trip_id)
    end

    test "returns :error for an invalid trip" do
      assert :error = route_direction_id("made up trip")
    end
  end

  describe "trip_name_headsign/1" do
    test "returns {:ok, trip_name, trip_headsign} for a valid ID" do
      assert trip_name_headsign(@trip_id) == {:ok, @trip_name, "North Station"}
    end

    test "returns :error for an invalid trip" do
      assert trip_name_headsign("") == :error
      assert trip_name_headsign("made up trip") == :error
    end
  end

  describe "route_trip_name_to_id/2" do
    test "returns {:ok, trip_id, direction_id} for a value route + name" do
      assert {:ok, @trip_id, @direction_id} ==
               route_trip_name_to_id(@route_id, @trip_name)
    end

    test "returns an error if we can't match the name" do
      assert :error == route_trip_name_to_id(@route_id, "not a trip")
    end
  end

  describe "handle_info(:timeout)" do
    test "clears the table and reschedules for the next day" do
      timeout = :timer.seconds(DateHelpers.seconds_until_next_service_date())
      assert {:noreply, :state, ^timeout} = handle_info(:timeout, :state)
      assert :ets.info(TripCache.Table, :size) == 0
    end
  end
end