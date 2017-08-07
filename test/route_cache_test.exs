defmodule RouteCacheTest do
  @moduledoc false
  use ExUnit.Case
  doctest RouteCache
  import RouteCache

  describe "id_from_long_name/1" do
    @route_name "Lowell Line"

    test "a valid route is cached" do
      assert {first_time, {:ok, _}} = :timer.tc(
        fn -> id_from_long_name(@route_name)
      end)
      assert {second_time, {:ok, _}} = :timer.tc(
        fn -> id_from_long_name(@route_name)
      end)
      assert second_time < first_time
    end
  end
end
