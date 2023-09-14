defmodule TrainLoc.S3.InMemory do
  @moduledoc """
  S3 behavior which keeps track of the uploads in memory.

  Used for testing.
  """
  @behaviour TrainLoc.S3

  @name __MODULE__

  @impl TrainLoc.S3
  def put_object(filename, body, bucket \\ :default, opts \\ [acl: :public_read]) do
    # incase it wasn't started yet
    start()

    Agent.update(@name, fn state ->
      Map.put(state, bucket, %{filename => body, "opts" => opts})
    end)

    {:ok, body}
  end

  def upload(filename, body, bucket, opts), do: put_object(filename, body, bucket, opts)

  def start do
    _ = Agent.start(fn -> %{} end, name: @name)
    :ok
  end

  def stop do
    Agent.stop(@name)
  end

  @spec list_objects :: any
  def list_objects do
    Agent.get(@name, & &1)
  end
end
