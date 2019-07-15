defmodule Busloc.LogHelper do
  @moduledoc "Helper functions for logging."

  @doc """
  Returns iodata suitable for logging representing a struct.

      iex> IO.iodata_to_binary(log_struct(%TestStruct{a: 1}))
      "TestStruct - a=1"

      iex> IO.iodata_to_binary(log_struct(%TestStruct{a: :b}))
      "TestStruct - a=b"

      iex> IO.iodata_to_binary(log_struct(%TestStruct{a: "b c d"}))
      ~s(TestStruct - a="b c d")

      iex> dt = DateTime.from_naive!(~N[1970-01-01T05:00:00], "Etc/UTC")
      iex> IO.iodata_to_binary(log_struct(%TestStruct{a: dt}))
      "TestStruct - a=1970-01-01T00:00:00-05:00"

      iex> IO.iodata_to_binary(log_struct(%TestVehicleStruct{vehicle_id: "0222", operator_id: "12345", assignment_timestamp: "2019-07-08T09:00:00-04:00"}))
      ~s(TestVehicleStruct - assign="2019-07-08T09:00:00-04:00" o_id="12345" v_id="0222")
  """
  def log_struct(%{__struct__: struct_name} = struct) do
    short_name = struct_name |> Module.split() |> List.last()

    log_parts =
      struct
      |> Map.from_struct()
      |> Enum.map(&log_line_item/1)
      |> Enum.intersperse(" ")

    [short_name, " - ", log_parts]
  end

  defp log_line_item({key, <<binary::binary>>}) do
    [key_string(key), ?=, inspect(binary)]
  end

  defp log_line_item({key, %DateTime{} = value}) do
    value = Busloc.Utilities.Time.in_busloc_tz(value)
    [key_string(key), ?=, DateTime.to_iso8601(value)]
  end

  defp log_line_item({key, value}) do
    [key_string(key), ?=, to_string(value)]
  end

  defp key_string(:source), do: "v_source"

  defp key_string(key) do
    case Atom.to_string(key) do
      "vehicle_" <> rest -> "v_" <> rest
      "operator_" <> rest -> "o_" <> rest
      "assignment_timestamp" <> rest -> "assign" <> rest
      binary -> binary
    end
  end
end
