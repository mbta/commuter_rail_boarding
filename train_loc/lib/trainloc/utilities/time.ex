defmodule TrainLoc.Utilities.Time do
  @moduledoc """
  Utility module for working with times
  """
  use Timex
  import TrainLoc.Utilities.ConfigHelpers

  @type datetime :: DateTime.t() | Timex.AmbiguousDateTime.t() | {:error, term}

  @spec in_local_tz(DateTime.t()) :: datetime
  @spec in_local_tz(DateTime.t(), Timex.Types.valid_timezone()) :: datetime
  def in_local_tz(dt, timezone \\ config(:time_zone)) do
    case dt do
      %DateTime{time_zone: ^timezone} -> dt
      dt -> Timex.to_datetime(dt, timezone)
    end
  end

  @spec unix_now() :: integer
  def unix_now() do
    System.system_time(:seconds)
  end

  def parse_improper_unix(local_unix, timezone \\ config(:time_zone))

  def parse_improper_unix(local_unix, timezone) when is_integer(local_unix) do
    date_time = DateTime.from_unix!(local_unix)

    offset =
      timezone
      |> Timezone.get(date_time)
      |> Timezone.total_offset()

    date_time
    |> Timezone.convert(timezone)
    |> Timex.shift(seconds: offset * -1)
  end

  def parse_improper_unix(_, _) do
    nil
  end

  @spec naive_parse_unix(integer) :: NaiveDateTime.t() | {:error, term}
  def naive_parse_unix(unix) when is_integer(unix) do
    unix
    |> DateTime.from_unix!()
    |> DateTime.to_naive()
  end

  @spec time_until(DateTime.t(), DateTime.t(), Timex.Comparable.granularity()) :: integer
  def time_until(time, from, units \\ :milliseconds) do
    Timex.diff(time, from, units)
  end

  @spec get_service_date(DateTime.t()) :: Date.t()
  def get_service_date(current_time \\ DateTime.utc_now()) do
    dt =
      current_time
      |> in_local_tz
      |> Timex.shift(hours: -3)
      |> case do
        %DateTime{} = dt -> dt
        %Timex.AmbiguousDateTime{before: before} -> before
      end

    DateTime.to_date(dt)
  end

  @spec parse_date(String.t()) :: Date.t()
  def parse_date(date_string) do
    case Timex.parse(date_string, "{YYYY}-{0M}-0{D}") do
      {:ok, date} -> date
      {:error, _} -> Timex.epoch()
    end
  end

  @spec format_datetime(DateTime.t()) :: String.t()
  def format_datetime(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end
end
