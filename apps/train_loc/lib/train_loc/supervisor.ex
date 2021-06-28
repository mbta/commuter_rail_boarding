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

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      {TrainLoc.Conflicts.State, [name: TrainLoc.Conflicts.State]},
      {TrainLoc.Vehicles.State, [name: TrainLoc.Vehicles.State]},
      {TrainLoc.Vehicles.PreviousBatch, [name: TrainLoc.Vehicles.PreviousBatch]}
    ]

    _ = Logger.debug(fn -> "Starting State supervisor..." end)
    Supervisor.init(children, strategy: :one_for_one)
  end
end
