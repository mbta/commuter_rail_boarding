defmodule Busloc.Utilities.TimeTest do
  use ExUnit.Case, async: true

  import Busloc.Utilities.Time
  import Busloc.Utilities.ConfigHelpers

  describe "parse_transitmaster_timestamp/2" do
    test "replaces h/m/s from datetime with values from Transitmaster" do
      base_datetime = Timex.to_datetime(~N[2018-03-26T14:46:00], "America/New_York")
      tm_timestamp = "154701"

      expected = Timex.to_datetime(~N[2018-03-26T15:47:01], "America/New_York")
      assert parse_transitmaster_timestamp(tm_timestamp, base_datetime) == expected
    end

    test "uses next day if the current time is after 10p and TM timestamp is before 4am" do
      base_datetime = Timex.to_datetime(~N[2018-03-26T22:46:00], "America/New_York")
      tm_timestamp = "034701"

      expected = Timex.to_datetime(~N[2018-03-27T03:47:01], "America/New_York")
      assert parse_transitmaster_timestamp(tm_timestamp, base_datetime) == expected
    end

    test "uses previous day if the current time is before 4a and TM timestamp is after 10pm" do
      base_datetime = Timex.to_datetime(~N[2018-03-26T03:46:00], "America/New_York")
      tm_timestamp = "224701"

      expected = Timex.to_datetime(~N[2018-03-25T22:47:01], "America/New_York")
      assert parse_transitmaster_timestamp(tm_timestamp, base_datetime) == expected
    end

    test "doesn't include milliseconds" do
      base_datetime = Timex.to_datetime(~N[2018-03-26T14:46:00.123], "America/New_York")
      tm_timestamp = "154701"

      expected = Timex.to_datetime(~N[2018-03-26T15:47:01], "America/New_York")
      assert parse_transitmaster_timestamp(tm_timestamp, base_datetime) == expected
    end
  end

  describe "in_busloc_tz/1" do
    test "returns a DateTime in the local timezone" do
      datetime = Timex.now() |> in_busloc_tz()

      assert datetime.time_zone == config(:time_zone)
    end
  end
end
