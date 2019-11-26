defmodule TrainLoc.LogAnalyzer.BlockConflicts do
  @moduledoc """
  Returns blocks with more than one vehicle assigned to them in a given logs
  file.

  """

  @spec run(String.t()) :: list
  def run(logs) do
    logs
    |> log_lines()
    |> blocks_and_vehicles()
    |> filter_blocks_with_multiple_vehicles()
    |> format()
  end

  defp log_lines(logs) do
    String.split(logs, "\n", trim: true)
  end

  defp blocks_and_vehicles(log_lines) do
    Enum.reduce(log_lines, %{}, &block_and_vehicle_reducer/2)
  end

  defp block_and_vehicle_reducer(log_line, acc) do
    [block] = Regex.run(~r/(?<=block=")(.*?)(?=")/, log_line, capture: :first)
    [vehicle] = Regex.run(~r/(?<=id=)(.*?)(?=\s)/, log_line, capture: :first)
    Map.update(acc, block, MapSet.new([vehicle]), &MapSet.put(&1, vehicle))
  end

  defp filter_blocks_with_multiple_vehicles(blocks_and_vehicles) do
    Enum.filter(blocks_and_vehicles, &multiple_vehicles?/1)
  end

  defp multiple_vehicles?({_block_id, vehicle_ids}) do
    MapSet.size(vehicle_ids) > 1
  end

  defp format(blocks_and_vehicles) do
    Enum.map(blocks_and_vehicles, &format_block/1)
  end

  defp format_block({block_id, vehicle_ids}) do
    %{
      block_id: block_id,
      conflicts: %{vehicle_ids: MapSet.to_list(vehicle_ids)}
    }
  end
end
