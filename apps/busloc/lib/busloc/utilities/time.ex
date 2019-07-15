defmodule Busloc.Utilities.Time do
  use Timex

  import Busloc.Utilities.ConfigHelpers
  import String, only: [to_integer: 1]

  @time_zone config(:time_zone)

  def now do
    {:ok, dt} = FastLocalDatetime.unix_to_datetime(System.system_time(:seconds), @time_zone)
    dt
  end

  def parse_transitmaster_timestamp(
        <<hour::binary-2, minute::binary-2, second::binary-2>>,
        base_datetime
      ) do
    hour = to_integer(hour)
    minute = to_integer(minute)
    second = to_integer(second)

    new_datetime = %{
      base_datetime
      | hour: hour,
        minute: minute,
        second: second,
        microsecond: {0, 0}
    }

    cond do
      base_datetime.hour >= 22 and new_datetime.hour <= 3 ->
        Timex.shift(new_datetime, days: 1)

      base_datetime.hour <= 3 and new_datetime.hour >= 22 ->
        Timex.shift(new_datetime, days: -1)

      true ->
        new_datetime
    end
  end

  def in_busloc_tz(%DateTime{} = dt) do
    {:ok, local_dt} = FastLocalDatetime.unix_to_datetime(DateTime.to_unix(dt), @time_zone)
    local_dt
  end

  def timestamp_stale(timestamp, now, stale_seconds) do
    !timestamp || DateTime.diff(now, timestamp) > stale_seconds
  end
end
