defmodule Parser do
  @moduledoc """
  Parser for PTIS data
  """

  def parse_line(line) do
    split_line = String.split(line, " - ")
    split_prefix = String.split_at(Enum.at(split_line,0), 22)
    {:ok, timestamp} = Timex.parse(elem(split_prefix, 0), "{0M}-{0D}-{YYYY} {0h12}:{0m}:{0s} {AM}")
    vehicle_id = elem(String.split_at(elem(split_prefix, 1), 12), 1)
    {timestamp, vehicle_id, Enum.at(split_line, 1)}
  end
end
