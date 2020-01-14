defmodule Mix.Tasks.BlockConflicts do
  use Mix.Task
  alias TrainLoc.LogAnalyzer.BlockConflicts

  @shortdoc "Finds blocks with multiple vehicle assignments"
  def run(logs_file_path) do
    conflicts =
      logs_file_path
      |> File.read!()
      |> BlockConflicts.run()

    IO.puts(Jason.encode!(conflicts))
  end
end
