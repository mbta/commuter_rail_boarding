defmodule Busloc.Fetcher.OperatorFetcherTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias Busloc.Operator
  import Busloc.Fetcher.OperatorFetcher

  describe "handle_info(:timeout)" do
    @tag :capture_log
    test "stores operator data in ets table" do
      {:ok, state} = init(:operator_fetcher_test)
      assert handle_info(:timeout, state) == {:noreply, state}

      assert {:ok,
              %Operator{
                vehicle_id: "0401",
                operator_name: "DIXON",
                operator_id: "65494",
                block: "Q225-84",
                run: "128-1407"
              }} == operator_by_vehicle_block(:operator_fetcher_test, "0401", "Q225-84")

      assert :error == operator_by_vehicle_block(:operator_fetcher_test, "1234", "5678")
    end

    @tag :capture_log
    test "deletes previous operators which are no longer present" do
      {:ok, state} = init(:operator_fetcher_test_delete)

      operator = %Operator{
        vehicle_id: "new",
        block: "new"
      }

      :ets.insert(state.table, {{operator.vehicle_id, operator.block}, operator})

      assert {:ok, ^operator} =
               operator_by_vehicle_block(
                 :operator_fetcher_test_delete,
                 operator.vehicle_id,
                 operator.block
               )

      handle_info(:timeout, state)

      assert :error ==
               operator_by_vehicle_block(
                 :operator_fetcher_test_delete,
                 operator.vehicle_id,
                 operator.block
               )
    end
  end

  describe "operator_by_vehicle_block when not started" do
    test "returns :error" do
      assert :error ==
               operator_by_vehicle_block(:operator_fetcher_test_not_started, "1234", "1234")
    end
  end
end
