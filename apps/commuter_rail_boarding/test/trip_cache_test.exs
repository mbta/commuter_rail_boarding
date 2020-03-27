defmodule TripCacheTest do
  @moduledoc false
  use ExUnit.Case

  import TripCache

  @route_id "CR-Lowell"
  @trip_name "1314"
  @trip_id "CR-Weekday-StormB-19-1314C0"
  @direction_id 1
  # need a roughly-current date in order to look it up in the API
  @datetime DateTime.utc_now()

  describe "route_direction_id/1" do
    # you can get one of these from the API: https://api-v3.mbta.com/trips/?filter[route]=1&filter[direction_id]=0&page[limit]=1
    @route_1_trip_id "43755420"
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

  describe "route_trip_name_to_id/3" do
    test "returns {:ok, trip_id, direction_id} for a value route + name" do
      assert {:ok, @trip_id, @direction_id} ==
               route_trip_name_to_id(@route_id, @trip_name, @datetime)
    end

    test "returns an error if we can't match the name" do
      assert :error == route_trip_name_to_id(@route_id, "not a trip", @datetime)
    end

    test "correctly finds a trip ID based on the date passed in" do
      # find the next Saturday
      day_of_week =
        @datetime |> DateHelpers.service_date() |> Date.day_of_week()

      unix = DateTime.to_unix(@datetime)
      unix_saturday = unix + 86_400 * (6 - day_of_week)
      saturday = DateTime.from_unix!(unix_saturday)
      assert route_trip_name_to_id("CR-Fitchburg", "0000", @datetime) == :error

      assert {:ok, "CR-" <> _, 0} =
               route_trip_name_to_id("CR-Fitchburg", "1409", saturday)
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
