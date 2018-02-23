defmodule TrainLoc.LogAnalyzer.BlockInferrerTest do
  use ExUnit.Case, async: true
  import TrainLoc.LogAnalyzer.BlockInferrer

  describe "run/1" do
    test "infers which trips are part of a block (and their order)" do
      logs = """
      2018-02-23 08:59:46.034 [info] Vehicle Assignment - id=1 trip="A" block="B"
      2018-02-23 08:58:46.034 [info] Vehicle Assignment - id=1 trip="B" block="B"
      2018-02-23 08:57:46.034 [info] Vehicle Assignment - id=2 trip="C" block="D"
      2018-02-23 08:56:46.034 [info] Vehicle Assignment - id=2 trip="D" block="D"
      """
      expected = [
        %{block_id: "B", trip_ids: ["B", "A"]},
        %{block_id: "D", trip_ids: ["D", "C"]},
      ]
      assert run(logs) == expected
    end

    test "duplicate trip ids are ignored" do
      logs = """
      2018-02-23 08:58:46.034 [info] Vehicle Assignment - id=1 trip="A" block="A"
      2018-02-23 08:57:46.034 [info] Vehicle Assignment - id=1 trip="A" block="A"
      """
      expected = [
        %{block_id: "A", trip_ids: ["A"]},
      ]
      assert run(logs) == expected
    end

    test "order is indicated by the first time a trip is logged" do
      # Note that the logs are in reverse order, so the trip IDs returned by
      # `run/1` are also in the reverse order from what one would expect
      # reading down the log.
      logs = """
      2018-02-23 08:58:46.034 [info] Vehicle Assignment - id=1 trip="A" block="C"
      2018-02-23 08:57:46.034 [info] Vehicle Assignment - id=1 trip="C" block="C"
      2018-02-23 08:56:46.034 [info] Vehicle Assignment - id=1 trip="B" block="C"
      2018-02-23 08:55:46.034 [info] Vehicle Assignment - id=1 trip="B" block="C"
      2018-02-23 08:54:46.034 [info] Vehicle Assignment - id=1 trip="A" block="C"
      2018-02-23 08:53:46.034 [info] Vehicle Assignment - id=1 trip="C" block="C"
      """
      expected = [
        %{block_id: "C", trip_ids: ["C", "A", "B"]},
      ]
      assert run(logs) == expected
    end
  end
end
