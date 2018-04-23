defmodule TrainLoc.Logging do
  @moduledoc """
  Standardizes the interface for logging key-values
  intended for Splunk.
  """

  @doc """
  Formats a title and map/keyword_list
  intended to be logged to splunk
  into an iolist.
  """
  def log_string(title, reason) when is_atom(reason) do
    log_string(title, %{reason: reason})
  end

  def log_string(title, params) when is_binary(title) when is_atom(title) do
    [format_title(title) | do_splunk_format(params)]
  end

  defp do_splunk_format(params) when is_map(params) do
    params
    |> Enum.into([])
    |> do_splunk_format
  end

  defp do_splunk_format([]) do
    []
  end

  defp do_splunk_format([last]) do
    do_splunk_format(last)
  end

  defp do_splunk_format([first | rest]) do
    [do_splunk_format(first), " " | do_splunk_format(rest)]
  end

  defp do_splunk_format({key, value}) do
    [to_string(key), "=", to_value(value)]
  end

  defp to_value(str) when is_binary(str) do
    # add quotes
    inspect(str)
  end

  defp to_value(list) when is_list(list) do
    Poison.encode!(list)
  end

  defp to_value(tuple) when is_tuple(tuple) do
    inspect(tuple)
  end

  defp to_value(x) do
    # safe for iolist
    to_string(x)
  end

  defp format_title(title) do
    [to_string(title), " - "]
  end
end
