defmodule TrainLoc.Utilities.Time do
  @moduledoc """
  Utility module for working with times
  """
  use Timex
  import TrainLoc.Utilities.ConfigHelpers

  # Week starts on Sunday
  @week_start 7

  @spec local_now(Timex.Types.valid_timezone) :: DateTime.t | Timex.AmbiguousDateTime.t | {:error, term}
  def local_now(timezone \\ config(:time_zone)) do
    Timex.now(timezone)
  end

  @spec unix_now() :: integer
  def unix_now() do
    local_now()
    |> Timex.to_unix()
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


  @spec naive_parse_unix(integer) :: NaiveDateTime.t | {:error, term}
  def naive_parse_unix(unix) when is_integer(unix) do
    unix
    |> DateTime.from_unix!
    |> DateTime.to_naive
  end

  @spec end_of_service_date(DateTime.t) :: DateTime.t
  def end_of_service_date(current_time \\ local_now()) do
    datetime =
      current_time
      |> Timex.end_of_day()
      |> Timex.shift(hours: 3)

    if current_time.hour < 3 do
      Timex.shift(datetime, days: -1)
    else
      datetime
    end
  end

  @spec end_of_week(DateTime.t) :: DateTime.t
  def end_of_week(current_time \\ local_now()) do
    week_end =
      current_time
      |> Timex.end_of_week(@week_start)
      |> Timex.shift([hours: 3])

    if current_time.hour < 3 and Timex.weekday(current_time) == @week_start do
      Timex.shift(week_end, weeks: -1)
    else
      week_end
    end
  end

  @spec first_day_of_week(DateTime.t) :: Date.t
  def first_day_of_week(current_time \\ local_now()) do
    current_time
    |> get_service_date()
    |> Timex.beginning_of_week(@week_start)
  end

  @spec time_until(DateTime.t, DateTime.t, Timex.Comparable.granularity) :: integer
  def time_until(time, from, units \\ :milliseconds) do
    Timex.diff(time, from, units)
  end

  @spec get_service_date(DateTime.t) :: Date.t
  def get_service_date(current_time \\ local_now()) do
    datetime = Timex.beginning_of_day(current_time)
    service_datetime =
    if current_time.hour < 3 do
      Timex.shift(datetime, days: -1)
    else
      datetime
    end
    Timex.to_date(service_datetime)
  end

  @spec format_date(Date.t) :: String.t
  def format_date(date) do
    Timex.format!(date, "{YYYY}-{0M}-{0D}")
  end

  @spec parse_date(String.t) :: Date.t
  def parse_date(date_string) do
    case Timex.parse(date_string, "{YYYY}-{0M}-0{D}") do
      {:ok, date} -> date
      {:error, _} -> Timex.epoch()
    end
  end

  @spec format_datetime(DateTime.t) :: String.t
  def format_datetime(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end
end
