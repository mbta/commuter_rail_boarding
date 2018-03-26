defmodule Busloc.Utilities.Time do
  use Timex

  import Busloc.Utilities.ConfigHelpers
  import String, only: [to_integer: 1]

  @tm_timestamp_regex ~r/(?<hour>\d{2})(?<minute>\d{2})(?<second>\d{2})/

  def parse_transitmaster_timestamp(tm_time, timezone \\ nil) do
    timezone = if timezone, do: timezone, else: config(:time_zone)

    %{"hour" => hour, "minute" => minute, "second" => second} =
      Regex.named_captures(@tm_timestamp_regex, tm_time)

    now = Timex.now(timezone)
    # TODO: Add time conversion logic from C++ app
    now
    |> Timex.set(hour: to_integer(hour), minute: to_integer(minute), second: to_integer(second))
    |> Timex.to_unix()
  end
end
