defmodule TripCacheTest do
  use ExUnit.Case

  import TripCache

  setup_all do
    Application.ensure_all_started(:httpoison)
    {:ok, _pid} = TripCache.start_link()
    :ok
  end

  describe "route_direction_id/1" do
    @route_1_trip_id "34543891"
    test "returns {:ok, route_id, direction_id} for a valid trip" do
      assert {:ok, "1", 0} = route_direction_id(@route_1_trip_id)
    end

    test "a valid trip is cached" do
      assert {first_time, {:ok, "1", 0}} = :timer.tc(fn -> route_direction_id(@route_1_trip_id) end)
      assert {second_time, {:ok, "1", 0}} = :timer.tc(fn -> route_direction_id(@route_1_trip_id) end)
      assert second_time < first_time
    end

    test "returns :error for an invalid trip" do
      assert :error = route_direction_id("made up trip")
    end
  end
end
