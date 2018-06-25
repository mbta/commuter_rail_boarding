defmodule Busloc.Waiver.Cmd.SqlcmdTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  import Busloc.Waiver.Cmd.Sqlcmd

  describe "sql/0" do
    test "includes the calendar_id" do
      assert sql() =~ calendar_id()
    end

    test "requests the selected fields" do
      actual = sql()

      for field <-
            ~w(TRIP_ID BLOCK_ID ROUTE_ID STOP_ID EARLY_ALLOWED_FLAG LATE_ALLOWED_FLAG MISSED_ALLOWED_FLAG NO_REVENUE_FLAG REMARK UPDATED_AT) do
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

  describe "calendar_id/0" do
    test "returns the service date prefixed with 1" do
      actual = calendar_id()
      assert <<?1, _::binary-8>> = actual
    end
  end

  describe "service_date/1" do
    test "returns the service date" do
      expected = ~D[2016-01-01]

      for time_str <- [
            "2016-01-01T03:00:00-05:00",
            "2016-01-01T12:00:00-05:00",
            "2016-01-02T02:59:59-05:00"
          ] do
        date_time = Timex.parse!(time_str, "{ISO:Extended}")
        assert {time_str, service_date(date_time)} == {time_str, expected}
      end
    end

    test "function handles an ambiguous datetime" do
      expected = ~D[2017-11-04]

      res =
        ~N[2017-11-05T01:59:00]
        |> Timex.to_datetime("America/New_York")
        |> service_date()

      assert res == expected
    end

    test "function handles shifting into ambiguous datetime" do
      expected = ~D[2017-11-05]

      res =
        ~N[2017-11-05T04:59:00]
        |> Timex.to_datetime("America/New_York")
        |> service_date()

      assert res == expected
    end

    test "handles shifting back across DST" do
      expected = ~D[2017-11-04]

      res =
        ~N[2017-11-05T02:59:00]
        |> Timex.to_datetime("America/New_York")
        |> service_date()

      assert res == expected
    end
  end
end
