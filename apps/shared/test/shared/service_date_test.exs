defmodule ServiceDateTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Shared.ServiceDate

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
      assert ~D[2018-03-11] = service_date(local_dt!(~N[2018-03-11T03:30:00]))
      assert ~D[2018-03-11] = service_date(local_dt!(~N[2018-03-11T04:30:00]))
      # fall back
      {:ambiguous, dt_one, dt_two} = local_dt(~N[2018-11-04T01:30:00])

      for local_dt <- [dt_one, dt_two] do
        {:ok, utc_datetime} = DateTime.shift_zone(local_dt, "Etc/UTC")
        assert ~D[2018-11-03] = service_date(utc_datetime)
      end

      assert ~D[2018-11-03] = service_date(local_dt!(~N[2018-11-04T02:30:00]))
      assert ~D[2018-11-04] = service_date(local_dt!(~N[2018-11-04T03:30:00]))
    end
  end

  describe "seconds_until_next_service_date/1" do
    test "handles non-DST" do
      assert 3601 =
               seconds_until_next_service_date(
                 service_date(local_dt!(~N[2018-02-11T01:59:59])),
                 local_dt!(~N[2018-02-11T01:59:59])
               )

      assert 84_600 =
               seconds_until_next_service_date(
                 service_date(local_dt!(~N[2018-02-11T03:30:00])),
                 local_dt!(~N[2018-02-11T03:30:00])
               )

      assert 81_000 =
               seconds_until_next_service_date(
                 service_date(local_dt!(~N[2018-02-11T04:30:00])),
                 local_dt!(~N[2018-02-11T04:30:00])
               )
    end

    test "DST - Spring Forward" do
      # spring forward
      # This is 1 second before the change, 1 second makes sense
      assert 1 =
               seconds_until_next_service_date(
                 service_date(local_dt!(~N[2018-03-11T01:59:59])),
                 local_dt!(~N[2018-03-11T01:59:59])
               )

      # This is 30 minutes after the change, so 23.5 hours makes sense:
      assert 84_600 =
               seconds_until_next_service_date(
                 service_date(local_dt!(~N[2018-03-11T03:30:00])),
                 local_dt!(~N[2018-03-11T03:30:00])
               )

      # At this point we are already a half hour past when it would have changed otherwise, so 22.5 hours makes sense:
      assert 81_000 =
               seconds_until_next_service_date(
                 service_date(local_dt!(~N[2018-03-11T04:30:00])),
                 local_dt!(~N[2018-03-11T04:30:00])
               )
    end

    test "DST - Fall Back" do
      {:ambiguous, dt_one, dt_two} = local_dt(~N[2018-11-04T01:30:00])

      # This checks that when the time goes back, the ambiguous hour is handled correctly.
      # Basically, the two times it is 1:30AM reference the correct amount of remaining seconds (5400, 1800)
      # for service date rollover.
      for {seconds_until, local_dt} <- %{5400 => dt_one, 1800 => dt_two} do
        {:ok, utc_datetime} = DateTime.shift_zone(local_dt, "Etc/UTC")

        assert seconds_until =
                 seconds_until_next_service_date(service_date(utc_datetime), utc_datetime)
      end

      # This is 30 minutes after the time going back, so .5 hour makes sense:
      assert 1800 =
               seconds_until_next_service_date(
                 service_date(local_dt!(~N[2018-11-04T02:30:00])),
                 local_dt!(~N[2018-11-04T02:30:00])
               )

      # This is 1.5h after the time going back, so 23.5 hours makes sense:
      assert 84_600 =
               seconds_until_next_service_date(
                 service_date(local_dt!(~N[2018-11-04T03:30:00])),
                 local_dt!(~N[2018-11-04T03:30:00])
               )
    end

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
