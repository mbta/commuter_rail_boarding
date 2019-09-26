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
                operator_name: "OPERATOR1",
                operator_id: "40404",
                block: "Q225-84",
                run: "123-1508"
              }} == operator_by_vehicle_run(:operator_fetcher_test, "0401", "123-1508")

      assert :error == operator_by_vehicle_run(:operator_fetcher_test, "1234", "123-5678")
      assert :error == operator_by_vehicle_run(:operator_fetcher_test, "0401", "128-1234")
    end

    @tag :capture_log
    test "deletes previous operators which are no longer present" do
      {:ok, state} = init(:operator_fetcher_test_delete)

      operator = %Operator{
        vehicle_id: "new",
        block: "newblock",
        run: "newrun"
      }

      :ets.insert(state.table, {{operator.vehicle_id, operator.run}, operator})

      assert {:ok, ^operator} =
               operator_by_vehicle_run(
                 :operator_fetcher_test_delete,
                 operator.vehicle_id,
                 operator.run
               )

      handle_info(:timeout, state)

      assert :error ==
               operator_by_vehicle_run(
                 :operator_fetcher_test_delete,
                 operator.vehicle_id,
                 operator.run
               )
    end
  end

  describe "operator_by_vehicle_run when not started" do
    test "returns :error" do
      assert :error ==
               operator_by_vehicle_run(:operator_fetcher_test_not_started, "1234", "123-1234")
    end
  end

  describe "init/1" do
    @tag :capture_log
    test "Sends a timeout on a failing db command" do
      {:ok, _state} =
        init({:operator_fetcher_test_db_fail, cmd: Busloc.Cmd.Failing, wait_for_db_connection: 1})

      assert_receive :timeout
    end
  end
end
