defmodule TrainLoc.LogAnalyzer.BlockInferrer do
  @moduledoc """
  Infers which trips are part of a given block (and their order) from a given
  vehicle assignment logs file.

  Note that the logs are in reverse order, so the trip IDs returned by
  `run/1` are also in the reverse order from what one would expect
  reading down the log.

  Logs example:

  ```
  2018-02-23 08:59:46.034 [info] Vehicle Assignment - id=1 trip="A" block="B"
  2018-02-23 08:58:46.034 [info] Vehicle Assignment - id=1 trip="B" block="B"
  2018-02-23 08:57:46.034 [info] Vehicle Assignment - id=2 trip="C" block="D"
  2018-02-23 08:56:46.034 [info] Vehicle Assignment - id=2 trip="D" block="D"
  ```

  In the example above the first trip for block D is trip D and the second one
  trip C. For block B, the first trip is trip B and the second one trip A.

  """

  @spec run(String.t()) :: list
  def run(logs) do
    logs
    |> log_lines()
    |> blocks_and_trips()
    |> format()
  end

  defp log_lines(logs) do
    # to process earliest logs first
    logs
    |> String.split("\n", trim: true)
    |> Enum.reverse()
  end

  defp blocks_and_trips(log_lines) do
    Enum.reduce(log_lines, %{}, &block_and_trip_reducer/2)
  end

  defp block_and_trip_reducer(log_line, acc) do
    [block] = Regex.run(~r/(?<=block=")(.*?)(?=")/, log_line, capture: :first)
    [trip] = Regex.run(~r/(?<=trip=")(.*?)(?=")/, log_line, capture: :first)
    Map.update(acc, block, [trip], &List.insert_at(&1, 0, trip))
  end

  defp format(blocks_and_trips) do
    Enum.map(blocks_and_trips, &format_block/1)
  end

  defp format_block({block_id, trip_ids}) do
    final_trip_ids = trip_ids |> Enum.reverse() |> Enum.uniq()
    %{block_id: block_id, trip_ids: final_trip_ids}
  end
end
