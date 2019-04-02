defmodule Busloc.Operator.Parse do
  @moduledoc """
  Parse the output of `Busloc.Operator.Cmd.operator_cmd/0` into a list of %Operator{}s.
  """
  alias Busloc.Operator

  @line_splitter ~r/\r?\n/
  @col_splitter ~r/\s*,\s*/

  @type key :: {String.t(), String.t()}

  @spec parse(String.t()) :: [Operator.t()]
  def parse(data) do
    rows = Regex.split(@line_splitter, data)
    [headers, _ignored | rest] = rows
    headers = split_and_trim(@col_splitter, headers)

    for row <- rest,
        row = String.trim_leading(row),
        columms = split_and_trim(@col_splitter, row),
        header_column_pairs = Enum.zip(headers, columms),
        map = Map.new(header_column_pairs),
        operator <- to_operator(map) do
      operator
    end
  end

  @spec to_operator(map) :: [Operator.t()]
  def to_operator(%{
        "vehicle_id" => vehicle_id,
        "block_id" => block_id,
        "operator_name" => operator_name,
        "operator_id" => operator_id,
        "run_id" => run_id
      }) do
    [
      %Operator{
        vehicle_id: vehicle_id,
        operator_name: operator_name,
        operator_id: operator_id,
        block: block_id,
        run: run_id
      }
    ]
  end

  def to_operator(_), do: []

  defp split_and_trim(regex, string) do
    regex
    |> Regex.split(string)
    |> Enum.map(&String.trim/1)
  end
end
