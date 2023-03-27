defmodule Shared.ServiceDate do
  @moduledoc """
  Helper functions for working with Service Date
  """

  @timezone "America/New_York"

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
    local_time =
      dt
      |> ensure_timezone(@timezone)

    # Determine the number of days to "add" for the before-3am on next day case:
    days_to_add =
      if local_time.hour < 3 do
        -1
      else
        0
      end

    local_time
    |> DateTime.add(days_to_add, :day)
    |> DateTime.to_date()
  end

  @doc """
  Returns the number of seconds until the next service date starts.

  Useful for scheduling a timeout when the next day starts.
  """
  @spec seconds_until_next_service_date :: non_neg_integer
  def seconds_until_next_service_date do
    service_date()
    |> seconds_until_next_service_date(DateTime.utc_now())
  end

  def seconds_until_next_service_date(%Date{} = start_service_date, %DateTime{} = current_time) do
    tomorrow = Date.add(start_service_date, 1)

    {:ok, naive} = NaiveDateTime.new(tomorrow, ~T[03:00:00])

    {:ok, next_service_start} =
      DateTime.from_naive(
        naive,
        @timezone
      )

    microseconds = DateTime.diff(next_service_start, current_time, :microsecond)

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
