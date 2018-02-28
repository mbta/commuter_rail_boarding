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
    service_date(Calendar.DateTime.now!(@timezone))
  end

  def service_date(%DateTime{} = dt) do
    dt
    |> Calendar.DateTime.subtract!(@three_hours_in_seconds)
    |> DateTime.to_date()
  end

  @doc """
  Returns the number of seconds until the next service date starts.

  Useful for scheduling a timeout when the next day starts.
  """
  @spec seconds_until_next_service_date :: non_neg_integer
  def seconds_until_next_service_date do
    today = service_date()
    {:ok, tomorrow} = Calendar.Date.add(today, 1)

    {:ok, next_service_start} =
      Calendar.DateTime.from_date_and_time_and_zone(
        tomorrow,
        ~T[03:00:00],
        @timezone
      )

    {:ok, seconds, microseconds, _} =
      Calendar.DateTime.diff(next_service_start, DateTime.utc_now())

    # we want to return an integer, so we floor_div the seconds +
    # microseconds. the negatives make sure we floor towards
    # negative-infinity (getting a larger number)
    -Integer.floor_div(seconds * 1_000_000 + microseconds, -1_000_000)
  end
end
