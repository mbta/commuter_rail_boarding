defmodule Busloc.Uploader do
  @moduledoc """
  Behavior for uploading a file.

  Defines a function, `upload/1` which takes the binary file.
  """
  @callback upload(binary) :: :ok

  def upload(binary) do
    Application.get_env(:busloc, :uploader).upload(binary)
  end
end
