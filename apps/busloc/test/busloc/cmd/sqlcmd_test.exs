defmodule Busloc.Cmd.SqlcmdTest do
  use ExUnit.Case
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

  describe "cmd_list/1" do
    test "list includes the SQL query" do
      assert "sql query" in cmd_list("sql query")
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
          "operator_name" => "SHUTTLEDRIVER1",
          "operator_id" => "10101",
          "block_id" => "9990501",
          "run_id" => "9990501"
        },
        %{
          "vehicle_id" => "0688",
          "operator_name" => "SHUTTLEDRIVER2",
          "operator_id" => "20202",
          "block_id" => "9990501",
          "run_id" => "9990501"
        },
        %{
          "vehicle_id" => "0907",
          "operator_name" => "SHUTTLEDRIVER3",
          "operator_id" => "30303",
          "block_id" => "9990502",
          "run_id" => "9990502"
        }
      ]

      assert parse(cmd.shuttle_cmd()) == expected
    end
  end
end
