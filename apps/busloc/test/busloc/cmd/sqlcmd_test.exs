defmodule Busloc.Cmd.SqlcmdTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  import Busloc.Cmd.Sqlcmd

  describe "sql/0" do
    test "requests the selected fields" do
      actual = sql()

      for field <- ~w(PROPERTY_TAG LAST_NAME ONBOARD_LOGON_ID BLOCK_ABBR RUN_DESIGNATOR) do
        assert actual =~ field
      end
    end
  end

  describe "can_connect?" do
    test "returns a boolean" do
      assert can_connect?() in [true, false]
    end
  end

  describe "cmd_list/0" do
    test "logs the query" do
      log =
        capture_log(fn ->
          _ = cmd_list()
        end)

      assert log =~ "TM query"
    end

    @tag :capture_log
    test "list includes the SQL query" do
      assert sql() in cmd_list()
    end
  end
end
