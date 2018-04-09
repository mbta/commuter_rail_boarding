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

  @spec parse_improper_iso(String.t() | nil) :: datetime | nil
  @spec parse_improper_iso(String.t() | nil, String.t()) :: datetime | nil
  def parse_improper_iso(improper_iso, timezone \\ config(:time_zone))

  def parse_improper_iso(improper_iso, timezone) when is_binary(improper_iso) do
    improper_iso
    |> String.trim_trailing("Z")
    |> NaiveDateTime.from_iso8601!()
    |> Timex.to_datetime(timezone)
  end

  def parse_improper_iso(nil, _timezone) do
    nil
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

  @spec format_datetime(DateTime.t()) :: String.t()
  def format_datetime(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end
end
