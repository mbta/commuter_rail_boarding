defmodule TrainLoc.Utilities.Time do
  @moduledoc """
  Utility module for working with times
  """
  use Timex
  import TrainLoc.Utilities.ConfigHelpers

  @type datetime :: DateTime.t() | Timex.AmbiguousDateTime.t() | {:error, term}

  @spec unix_now() :: integer
  def unix_now do
    System.system_time(:second)
  end

  @spec parse_improper_iso(String.t() | nil) :: datetime | nil
  @spec parse_improper_iso(String.t() | nil, String.t()) :: datetime | nil
  def parse_improper_iso(improper_iso, timezone \\ config(:time_zone))

  def parse_improper_iso(improper_iso, _timezone) when is_binary(improper_iso) do
    improper_iso
    |> NaiveDateTime.from_iso8601!()
    |> Timex.to_datetime()
    |> drop_microsecond
  end

  def parse_improper_iso(nil, _timezone) do
    nil
  end

  defp drop_microsecond(%{microsecond: {0, _}} = dt) do
    # truncate off microsecond value if we didn't have any
    %{dt | microsecond: {0, 0}}
  end

  defp drop_microsecond(%{} = dt) do
    dt
  end

  @spec format_datetime(DateTime.t()) :: String.t()
  def format_datetime(datetime) do
    Timex.format!(datetime, "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end
end
