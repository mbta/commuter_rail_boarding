defmodule DateHelpers do
  @moduledoc """
  Helper functions for working with Dates
  """

  @timezone "America/New_York"
  @three_hours_in_seconds 60 * 60 * 3

  @doc """
  Returns the current service date.

  A service date runs from 3am - 2:59:59 the next morning.
  """
  @spec service_date :: Date.t()
  @spec service_date(DateTime.t()) :: Date.t()
  def service_date do
    {:ok, now} = DateTime.now(@timezone)
    service_date(now)
  end

  def service_date(%DateTime{} = dt) do
    dt
    |> ensure_timezone(@timezone)
    |> DateTime.add(-@three_hours_in_seconds)
    |> DateTime.to_date()
  end

  @doc """
  Returns the number of seconds until the next service date starts.

  Useful for scheduling a timeout when the next day starts.
  """
  @spec seconds_until_next_service_date :: non_neg_integer
  def seconds_until_next_service_date do
    today = service_date()
    tomorrow = Date.add(today, 1)
    {:ok, naive} = NaiveDateTime.new(tomorrow, ~T[03:00:00])

    {:ok, next_service_start} =
      DateTime.from_naive(
        naive,
        @timezone
      )

    microseconds = DateTime.diff(next_service_start, DateTime.utc_now(), :microsecond)

    # we want to return an integer, so we floor_div the seconds +
    # microseconds. the negatives make sure we floor towards
    # negative-infinity (getting a larger number)
    -Integer.floor_div(microseconds, -1_000_000)
  end

  defp ensure_timezone(%DateTime{time_zone: timezone} = dt, timezone) do
    # already in the right timezone
    dt
  end

  defp ensure_timezone(dt, timezone) do
    {:ok, dt} = DateTime.shift_zone(dt, timezone)
    dt
  end
end
