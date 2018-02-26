defmodule TrainLoc.LogAnalyzer.BlockConflictsTest do
  use ExUnit.Case, async: true
  import TrainLoc.LogAnalyzer.BlockConflicts

  describe "run/1" do
    test "returns empty list if no conflicts" do
      logs = """
      2018-02-23 08:59:46.034 [info] Vehicle Assignment - id=2 trip="B" block="B"
      2018-02-23 08:55:46.034 [info] Vehicle Assignment - id=1 trip="D" block="D"
      """
      assert run(logs) == []
    end

    test "returns blocks with more than one vehicle assigned to them" do
      logs = """
      2018-02-23 08:59:46.034 [info] Vehicle Assignment - id=2 trip="A" block="B"
      2018-02-23 08:58:46.034 [info] Vehicle Assignment - id=3 trip="F" block="B"
      2018-02-23 08:58:46.034 [info] Vehicle Assignment - id=2 trip="B" block="B"
      2018-02-23 08:57:46.034 [info] Vehicle Assignment - id=1 trip="C" block="D"
      2018-02-23 08:56:46.034 [info] Vehicle Assignment - id=1 trip="E" block="D"
      2018-02-23 08:55:46.034 [info] Vehicle Assignment - id=1 trip="D" block="D"
      """
      assert run(logs) == [
        %{block_id: "B", conflicts: %{vehicle_ids: ["2", "3"]}},
      ]
    end
  end
end
