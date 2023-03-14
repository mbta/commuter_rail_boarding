defmodule DateHelpers do
  @moduledoc """
  Helper functions for working with Dates
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

    dst = get_dst_info(local_time)

    # This condition handles the case where we preserve the service time that would otherwise be lost or gained
    # on the specific spring forward / fall back day. Essentially, "delay" by an hour in March and "advance" by an hour
    # in November.
    days_to_add =
      cond do
        dst.is_march_timechange_date and local_time.hour < 4 ->
          -1

        dst.is_nov_timechange_date and local_time.hour < 2 ->
          -1

        local_time.hour < 3 and not dst.is_nov_timechange_date and
            not dst.is_march_timechange_date ->
          -1

        true ->
          0
      end

    local_time
    |> NaiveDateTime.add(days_to_add, :day)
    |> NaiveDateTime.to_date()
  end

  defp get_dst_info(%DateTime{} = dt) do
    day_of_week = Date.day_of_week(dt)

    %{
      day_of_week: day_of_week,
      is_march_timechange_date:
        dt.month == 3 and dt.day >= 8 and dt.day <= 14 and day_of_week == 7,
      is_nov_timechange_date: dt.month == 11 and dt.day >= 1 and dt.day <= 7 and day_of_week == 7
    }
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
    dst = get_dst_info(current_time)

    # Like the condition above, we need to account for the time shift on the "next" service date calculation, to
    # avoid negative deltas:
    start_time =
      cond do
        dst.is_march_timechange_date -> ~T[04:00:00]
        dst.is_nov_timechange_date -> ~T[02:00:00]
        true -> ~T[03:00:00]
      end

    {:ok, naive} = NaiveDateTime.new(tomorrow, start_time)

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
