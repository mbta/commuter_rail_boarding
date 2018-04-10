defmodule Busloc.Uploader do
  @moduledoc """
  Behavior for uploading a file.

  Defines a function, `upload/1` which takes the binary file.
  """
  @callback upload(binary) :: :ok
  @callback post_nextbus(binary) :: binary

  def upload(binary) do
    Application.get_env(:busloc, :uploader).upload(binary)
  end

  def post_nextbus(binary) do
    Application.get_env(:busloc, :uploader).post_nextbus(binary)
  end
end
