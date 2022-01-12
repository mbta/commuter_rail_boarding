defmodule TripCacheTest do
  @moduledoc false
  use ExUnit.Case

  import TripCache

  @route_id "CR-Worcester"
  # need a roughly-current date in order to look it up in the API
  @datetime DateTime.utc_now()

  describe "route_direction_id/1" do
    test "returns :error for an invalid trip" do
      assert :error = route_direction_id("made up trip")
    end
  end

  describe "trip_name_headsign/1" do
    test "returns :error for an invalid trip" do
      assert trip_name_headsign("") == :error
      assert trip_name_headsign("made up trip") == :error
    end
  end

  describe "route_trip_name_to_id/3" do
    test "returns an error if we can't match the name" do
      assert :error == route_trip_name_to_id(@route_id, "not a trip", @datetime)
    end

    test "correctly finds a trip ID based on the date passed in" do
      assert route_trip_name_to_id("CR-Worcester", "0000", @datetime) == :error
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
