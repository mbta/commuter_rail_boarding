defmodule Busloc.LogHelper do
  @moduledoc "Helper functions for logging."

  @doc """
  Returns a string suitable for logging representing a struct.

      iex> log_struct(%TestStruct{a: 1})
      "TestStruct - a=1"

      iex> log_struct(%TestStruct{a: "b c d"})
      ~s(TestStruct - a="b c d")

      iex> dt = DateTime.from_naive!(~N[1970-01-01T05:00:00], "Etc/UTC")
      iex> log_struct(%TestStruct{a: dt})
      "TestStruct - a=1970-01-01T00:00:00-05:00"
  """
  def log_struct(%{__struct__: struct_name} = struct) do
    short_name = struct_name |> Module.split() |> List.last()

    log_parts =
      struct
      |> Map.from_struct()
      |> Enum.map(&log_line_item/1)
      |> Enum.join(" ")

    "#{short_name} - #{log_parts}"
  end

  defp log_line_item({key, value}) when is_binary(value) do
    "#{key}=#{inspect(value)}"
  end

  defp log_line_item({key, %DateTime{} = value}) do
    value = Busloc.Utilities.Time.in_busloc_tz(value)
    "#{key}=#{DateTime.to_iso8601(value)}"
  end

  defp log_line_item({key, value}) do
    "#{key}=#{value}"
  end
end
