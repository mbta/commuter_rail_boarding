defmodule Busloc.Waiver.Parse do
  @moduledoc """
  Parse the output of `Busloc.Waiver.Cmd.cmd/0` into a list of %Waiver{}s.
  """
  alias Busloc.Waiver

  @line_splitter ~r/\r?\n/
  @col_splitter ~r/\s*,\s*/

  @spec parse(String.t()) :: [Waiver.t()]
  def parse(data) do
    rows = Regex.split(@line_splitter, data)
    [headers, _ignored | rest] = rows
    headers = Regex.split(@col_splitter, headers)

    for row <- rest,
        row = String.trim_leading(row),
        waiver <- to_waiver(Map.new(Enum.zip(headers, Regex.split(@col_splitter, row)))) do
      waiver
    end
  end

  @spec to_waiver(map) :: [Waiver.t()]
  def to_waiver(%{"UPDATED_AT" => _} = map) do
    naive_updated_at =
      Timex.parse!(Map.fetch!(map, "UPDATED_AT"), "{YYYY}-{0M}-{0D} {h24}:{m}:{s}{ss}")

    updated_at = Timex.to_datetime(naive_updated_at, "America/New_York")

    [
      %Waiver{
        route_id: String.trim_leading(Map.fetch!(map, "ROUTE_ID"), "0"),
        block_id: Map.fetch!(map, "BLOCK_ID"),
        trip_id: Map.fetch!(map, "TRIP_ID"),
        stop_id: Map.fetch!(map, "STOP_ID"),
        updated_at: updated_at,
        remark: Map.fetch!(map, "REMARK"),
        early_allowed?: Map.fetch!(map, "EARLY_ALLOWED_FLAG") == "1",
        late_allowed?: Map.fetch!(map, "LATE_ALLOWED_FLAG") == "1",
        missed_allowed?: Map.fetch!(map, "MISSED_ALLOWED_FLAG") == "1",
        no_revenue?: Map.fetch!(map, "NO_REVENUE_FLAG") == "1"
      }
    ]
  end

  def to_waiver(%{"TRIP_ID" => _}) do
    []
  end
end
