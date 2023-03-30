defmodule TrainLoc.Utilities.TimeTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import TrainLoc.Utilities.Time
  import TrainLoc.Utilities.ConfigHelpers

  @timezone config(:time_zone)

  describe "parse_improper_iso/2" do
    test "converts ISO8601 string specifying UTC to same DateTime in given timezone" do
      test_string = "2018-03-28T12:34:56Z"
      actual = parse_improper_iso(test_string, @timezone)

      expected = ~U[2018-03-28 12:34:56Z]

      assert actual == expected
    end

    test "handles millisecond and microsecond precision in string" do
      milli_string = "2018-03-28T01:23:45.678Z"
      milli_actual = parse_improper_iso(milli_string, @timezone)
      milli_expected = ~U[2018-03-28 01:23:45.678Z]

      assert milli_actual == milli_expected

      micro_string = "2018-03-28T01:23:45.678910Z"
      micro_actual = parse_improper_iso(micro_string, @timezone)
      micro_expected = ~U[2018-03-28 01:23:45.678910Z]

      assert micro_actual == micro_expected
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
