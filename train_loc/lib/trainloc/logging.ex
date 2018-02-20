defmodule TrainLoc.Logging do

  @doc """
  Formats a title and map/keyword_list
  intended to be logged to splunk
  into an iolist.
  """
  def log_string(title, %module{} = struct_thing) do
    message = 
      struct_thing
      |> Map.from_struct # removes :__struct__ field
      |> Map.put(:_struct, module |> pretty_module)
    log_string(title, message)
  end
  def log_string(title, params) when is_binary(title) when is_atom(title) do
    [ format_title(title) | do_splunk_format(params) ]
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
  defp do_splunk_format([first | rest ]) do
    [ do_splunk_format(first), " " | do_splunk_format(rest) ]
  end
  defp do_splunk_format({key, value}) do
    [to_string(key), "=", to_value(value)]
  end

  defp to_value(str) when is_binary(str) do
    inspect(str) # add quotes
  end
  defp to_value(list) when is_list(list) do
    Poison.encode!(list)
  end
  defp to_value(tuple) when is_tuple(tuple) do
    inspect(tuple)
  end
  defp to_value(x) do
    to_string(x) # safe for iolist
  end

  defp format_title(title) do
    [to_string(title), " - "]
  end

  defp pretty_module(module) do
    module
    |> Module.split
    |> Enum.join(".")
  end

end