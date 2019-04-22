defmodule DateHelpersTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import DateHelpers

  describe "service_date/1" do
    test "returns the current date if it's 3am or after" do
      assert ~D[2017-01-01] = service_date(local_dt!(~N[2017-01-01T03:00:00]))
      assert ~D[2017-01-01] = service_date(local_dt!(~N[2017-01-01T15:00:00]))
      assert ~D[2017-01-01] = service_date(local_dt!(~N[2017-01-01T23:59:59]))
    end

    test "returns the previous date if it's between midnight and 3am" do
      assert ~D[2016-12-31] = service_date(local_dt!(~N[2017-01-01T00:00:00]))
      assert ~D[2016-12-31] = service_date(local_dt!(~N[2017-01-01T02:59:59]))
    end

    test "handles both DST transitions" do
      # spring forward
      assert ~D[2018-03-10] = service_date(local_dt!(~N[2018-03-11T01:59:59]))
      assert ~D[2018-03-10] = service_date(local_dt!(~N[2018-03-11T03:30:00]))
      assert ~D[2018-03-11] = service_date(local_dt!(~N[2018-03-11T04:30:00]))
      # fall back
      {:ambiguous, dt_one, dt_two} = local_dt(~N[2018-11-04T01:30:00])

      for local_dt <- [dt_one, dt_two] do
        {:ok, utc_datetime} = DateTime.shift_zone(local_dt, "Etc/UTC")
        assert ~D[2018-11-03] = service_date(utc_datetime)
      end

      assert ~D[2018-11-04] = service_date(local_dt!(~N[2018-11-04T02:30:00]))
      assert ~D[2018-11-04] = service_date(local_dt!(~N[2018-11-04T03:30:00]))
    end
  end

  describe "seconds_until_next_service_date/1" do
    test "returns a number of seconds until 3am tomorrow" do
      seconds = seconds_until_next_service_date()
      {:ok, now} = DateTime.now("America/New_York")
      tomorrow = DateTime.add(now, seconds, :second)
      assert {tomorrow.hour, tomorrow.minute, tomorrow.second} == {3, 0, 0}
    end
  end

  defp local_dt(%NaiveDateTime{} = ndt) do
    with {:ok, local_dt} <-
           DateTime.from_naive(
             ndt,
             "America/New_York"
           ) do
      DateTime.shift_zone(local_dt, "Etc/UTC")
    end
  end

  defp local_dt!(%NaiveDateTime{} = ndt) do
    {:ok, dt} = local_dt(ndt)
    dt
  end
end
