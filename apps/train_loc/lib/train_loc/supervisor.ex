defmodule TrainLoc.Supervisor do
  @moduledoc """
  Supervises processes which track our knowledge of:

  1. Assignment conflicts (TrainLoc.Conflicts.State).
  2. Latest vehicle data (TrainLoc.Vehicles.State).
  3. Vehicle data received in previously processed batch
     (TrainLoc.Vehicles.PreviousBatch).

  """

  use Supervisor

  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(TrainLoc.Conflicts.State, [[name: TrainLoc.Conflicts.State]]),
      worker(TrainLoc.Vehicles.State, [[name: TrainLoc.Vehicles.State]]),
      worker(TrainLoc.Vehicles.PreviousBatch, [
        [name: TrainLoc.Vehicles.PreviousBatch]
      ])
    ]

    _ = Logger.debug(fn -> "Starting State supervisor..." end)
    supervise(children, strategy: :one_for_one)
  end
end
