defmodule Busloc.Utilities.Time do
  use Timex

  import Busloc.Utilities.ConfigHelpers
  import String, only: [to_integer: 1]

  def now do
    Timex.now(config(:time_zone))
  end

  def parse_transitmaster_timestamp(
        <<hour::binary-2, minute::binary-2, second::binary-2>>,
        base_datetime
      ) do
    new_datetime =
      Timex.set(
        base_datetime,
        hour: to_integer(hour),
        minute: to_integer(minute),
        second: to_integer(second)
      )

    cond do
      base_datetime.hour >= 22 and new_datetime.hour <= 3 ->
        Timex.shift(new_datetime, days: 1)

      base_datetime.hour <= 3 and new_datetime.hour >= 22 ->
        Timex.shift(new_datetime, days: -1)

      true ->
        new_datetime
    end
  end
end
