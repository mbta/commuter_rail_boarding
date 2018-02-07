defmodule TrainLoc.S3.InMemory do
  @behaviour TrainLoc.S3

  @name __MODULE__

  @impl TrainLoc.S3
  def put_object(filename, body) do
    start() # incase it wasn't started yet
    Agent.update(@name, fn state ->
      Map.put(state, filename, body)
    end)

    {:ok, body}
  end

  def start() do
    Agent.start(fn -> %{} end, name: @name)
  end

  def get_object(filename) do
    start() # incase it wasn't started yet
    Agent.get(@name, fn state -> Map.get(state, filename) end)
  end

  def list_objects() do
    start() # incase it wasn't started yet
    Agent.get(@name, &(&1))
  end
end
