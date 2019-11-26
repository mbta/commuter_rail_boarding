defmodule TrainLoc.S3.InMemory do
  @moduledoc """
  S3 behavior which keeps track of the uploads in memory.

  Used for testing.
  """
  @behaviour TrainLoc.S3

  @name __MODULE__

  @impl TrainLoc.S3
  def put_object(filename, body) do
    # incase it wasn't started yet
    start()

    Agent.update(@name, fn state ->
      Map.put(state, filename, body)
    end)

    {:ok, body}
  end

  def start do
    Agent.start(fn -> %{} end, name: @name)
  end

  def list_objects do
    # incase it wasn't started yet
    start()
    Agent.get(@name, & &1)
  end
end
