defmodule TrainLoc.Utilities.TimeTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import TrainLoc.Utilities.Time
  import TrainLoc.Utilities.ConfigHelpers

  @timezone config(:time_zone)

  describe "in_local_tz/2" do
    test "converts DateTime to given timezone" do
      actual =
        ~N[2018-03-28T12:34:56]
        |> Timex.to_datetime("Etc/UTC")
        |> in_local_tz(@timezone)

      expected = Timex.to_datetime(~N[2018-03-28T08:34:56], @timezone)

      assert actual == expected
    end

    test "does nothing if DateTime is already in given timezone" do
      test_datetime = Timex.to_datetime(~N[2018-03-28T12:34:56], @timezone)

      assert in_local_tz(test_datetime, @timezone) == test_datetime
    end
  end

  describe "parse_improper_iso/2" do
    test "converts ISO8601 string specifying UTC to same DateTime in given timezone" do
      test_string = "2018-03-28T12:34:56Z"
      actual = parse_improper_iso(test_string, @timezone)

      expected = Timex.to_datetime(~N[2018-03-28T12:34:56], @timezone)

      assert actual == expected
    end

    test "handles millisecond and microsecond precision in string" do
      milli_string = "2018-03-28T01:23:45.678Z"
      milli_actual = parse_improper_iso(milli_string, @timezone)
      milli_expected = Timex.to_datetime(~N[2018-03-28T01:23:45.678], @timezone)

      assert milli_actual == milli_expected

      micro_string = "2018-03-28T01:23:45.678910Z"
      micro_actual = parse_improper_iso(micro_string, @timezone)

      micro_expected =
        Timex.to_datetime(~N[2018-03-28T01:23:45.678910], @timezone)

      assert micro_actual == micro_expected
    end
  end

  describe "get_service_date/1" do
    test "converts DateTime into Date" do
      actual =
        ~N[2018-03-28T12:34:56]
        |> Timex.to_datetime("Etc/UTC")
        |> get_service_date()

      expected = ~D[2018-03-28]

      assert actual == expected
    end

    test "converts to date based on local time, not UTC" do
      actual =
        ~N[2018-03-28T03:34:56]
        |> Timex.to_datetime("Etc/UTC")
        |> get_service_date()

      expected = ~D[2018-03-27]

      assert actual == expected
    end

    test "converts to previous date if local time is before 3am" do
      actual =
        ~N[2018-03-28T06:54:32]
        |> Timex.to_datetime("Etc/UTC")
        |> get_service_date()

      expected = ~D[2018-03-27]

      assert actual == expected
    end
  end

  describe "format_datetime/1" do
    test "converts to proper human-readable string" do
      actual =
        ~N[2018-03-28T12:34:56]
        |> Timex.to_datetime(@timezone)
        |> format_datetime()

      expected = "2018-03-28 12:34:56"

      assert actual == expected
    end

    test "output doesn't include milliseconds" do
      actual =
        ~N[2018-03-28T12:34:56.789]
        |> Timex.to_datetime(@timezone)
        |> format_datetime()

      expected = "2018-03-28 12:34:56"

      assert actual == expected
    end
  end
end
