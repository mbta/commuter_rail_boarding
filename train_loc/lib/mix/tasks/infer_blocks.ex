defmodule Mix.Tasks.InferBlocks do
  use Mix.Task
  alias TrainLoc.LogAnalyzer.BlockInferrer

  @shortdoc "Infers blocks from vehicle assignment logs"
  def run(logs_file_path) do
    blocks =
      logs_file_path
      |> File.read!()
      |> BlockInferrer.run()

    IO.puts(Poison.encode!(blocks))
  end
end
