defmodule Busloc.Fetcher.TmShuttleFetcherTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Busloc.TmShuttle
  import Busloc.Fetcher.TmShuttleFetcher

  describe "handle_info(:timeout)" do
    @tag :capture_log
    test "stores TM shuttle data in ets table" do
      {:ok, state} = init(:tm_shuttle_fetcher_test)
      assert handle_info(:timeout, state) == {:noreply, state}

      assert {:ok,
              %TmShuttle{
                vehicle_id: "1102",
                operator_name: "SHUTTLEDRIVER1",
                operator_id: "10101",
                block: "9990501",
                run: "9990501"
              }} == shuttle_assignment_by_vehicle(:tm_shuttle_fetcher_test, "1102")

      assert :error == shuttle_assignment_by_vehicle(:tm_shuttle_fetcher_test, "1234")
    end

    @tag :capture_log
    test "deletes previous shuttles which are no longer present" do
      {:ok, state} = init(:tm_shuttle_fetcher_test_delete)

      shuttle = %TmShuttle{
        vehicle_id: "new",
        block: "new"
      }

      :ets.insert(state.table, {shuttle.vehicle_id, shuttle})

      assert {:ok, ^shuttle} =
               shuttle_assignment_by_vehicle(
                 :tm_shuttle_fetcher_test_delete,
                 shuttle.vehicle_id
               )

      handle_info(:timeout, state)

      assert :error ==
               shuttle_assignment_by_vehicle(
                 :tm_shuttle_fetcher_test_delete,
                 shuttle.vehicle_id
               )
    end
  end

  describe "shuttle_assignment_by_vehicle when not started" do
    test "returns :error" do
      assert :error == shuttle_assignment_by_vehicle(:tm_shuttle_fetcher_test_not_started, "1234")
    end
  end
end
