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

  describe "assigned_logon_sql/0" do
    test "requests the selected fields for TM assigned logon query" do
      actual = assigned_logon_sql()

      for field <- ~w(PROPERTY_TAG TIME LAST_NAME ONBOARD_LOGON_ID BLOCK_ABBR RUN_DESIGNATOR) do
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
    test "logs the query" do
      log =
        capture_log(fn ->
          _ = cmd_list("sql query")
        end)

      assert log =~ "TM SQL command:"
    end

    test "list includes the SQL query" do
      assert "sql query" in cmd_list("sql query")
    end
  end

  describe "parse_tm_shuttle/1" do
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

  describe "parse_assigned_logon/1" do
    setup do
      cmd = Busloc.Utilities.ConfigHelpers.config(AssignedLogon, :cmd)
      %{cmd: cmd}
    end

    test "parses results of SQL query into map", %{cmd: cmd} do
      expected = [
        %{
          "vehicle_id" => "1416",
          "operator_name" => "ASSIGNEDDRIVER1",
          "operator_id" => "64646",
          "block_id" => "C66-123",
          "run_id" => "125-4201"
        },
        %{
          "vehicle_id" => "0699",
          "operator_name" => "ASSIGNEDDRIVER2",
          "operator_id" => "74747",
          "block_id" => "L441-145",
          "run_id" => "126-4090"
        },
        %{
          "vehicle_id" => "1294",
          "operator_name" => "ASSIGNEDDRIVER3",
          "operator_id" => "84848",
          "block_id" => "Q225-201",
          "run_id" => "128-4092"
        },
        %{
          "block_id" => "F137-900",
          "operator_id" => "94949",
          "operator_name" => "ASSIGNEDOVERRIDDEN",
          "run_id" => "126-9920",
          "vehicle_id" => "0401"
        }
      ]

      assert parse(cmd.assigned_logon_cmd()) == expected
    end
  end
end
