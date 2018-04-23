defmodule Busloc.Uploader do
  @moduledoc """
  Behavior for uploading a file.

  Defines a function, `upload/1` which takes the binary file.
  """
  @callback upload(binary) :: :ok

  @spec upload(binary) :: :ok
  def upload(binary) do
    for uploader <- Application.get_env(:busloc, :uploaders) do
      uploader.upload(binary)
    end

    :ok
  end
end
