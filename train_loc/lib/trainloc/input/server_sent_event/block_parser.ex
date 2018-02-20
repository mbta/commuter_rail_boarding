defmodule TrainLoc.Input.ServerSentEvent.BlockParser do

  def parse(string) do  
    string
    |> split_on_newlines
    |> parse_lines
  end
  def split_on_newlines(binary) when is_binary(binary) do
    String.split(binary, ~r/\r|\r\n|\n/, trim: true)
  end

  def parse_lines(parts) when is_list(parts) do
    Enum.reduce(parts, %{event: "", binary: ""}, &reduce_parse_line/2)
  end

  defp reduce_parse_line(":" <> _, acc) do
    # comment
    acc
  end
  defp reduce_parse_line("event:" <> rest, acc) do
    # event, can only be one
    %{acc | event: trim_one_space(rest)}
  end
  defp reduce_parse_line("data:" <> rest, acc) do
    # data, gets accumulated separated by newlines
    %{acc | binary: acc.binary <> trim_one_space(rest) <> "\n" }
  end
  defp reduce_parse_line(_, acc) do
    # ignored
    acc
  end

  def trim_one_space(" " <> rest), do: rest
  def trim_one_space(data), do: data

end