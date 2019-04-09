defmodule Busloc.Cmd.SqlcmdTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  import Busloc.Cmd.Sqlcmd

  describe "operator_sql/0" do
    test "requests the selected fields for operator query" do
      actual = operator_sql()

      for field <- ~w(PROPERTY_TAG LAST_NAME ONBOARD_LOGON_ID BLOCK_ABBR RUN_DESIGNATOR) do
        assert actual =~ field
      end
    end
  end

  describe "shuttle_sql/0" do
    test "requests the selected fields for TM shuttle query" do
      actual = shuttle_sql()

      for field <- ~w(PROPERTY_TAG LAST_NAME CURRENT_DRIVER MDT_BLOCK_ID SYSPARAM_FLAG) do
        assert actual =~ field
      end
    end
  end

  describe "can_connect?" do
    test "returns a boolean" do
      assert can_connect?() in [true, false]
    end
  end

  describe "operator_cmd_list/0" do
    test "logs the query" do
      log =
        capture_log(fn ->
          _ = operator_cmd_list()
        end)

      assert log =~ "TM operator query"
    end

    @tag :capture_log
    test "list includes the SQL query" do
      assert operator_sql() in operator_cmd_list()
    end
  end

  describe "shuttle_cmd_list/0" do
    test "logs the query" do
      log =
        capture_log(fn ->
          _ = shuttle_cmd_list()
        end)

      assert log =~ "TM shuttle query"
    end

    @tag :capture_log
    test "list includes the SQL query" do
      assert shuttle_sql() in shuttle_cmd_list()
    end
  end

  describe "parse/1" do
    setup do
      cmd = Busloc.Utilities.ConfigHelpers.config(TmShuttle, :cmd)
      %{cmd: cmd}
    end

    test "parses results of SQL query into map", %{cmd: cmd} do
      expected = [
        %{
          "vehicle_id" => "1102",
          "operator_name" => "DIXON",
          "operator_id" => "65494",
          "block_id" => "9990501",
          "run_id" => "9990501"
        },
        %{
          "vehicle_id" => "0688",
          "operator_name" => "SANDERS",
          "operator_id" => "71158",
          "block_id" => "9990501",
          "run_id" => "9990501"
        }
      ]

      assert parse(cmd.shuttle_cmd()) == expected
    end
  end
end
