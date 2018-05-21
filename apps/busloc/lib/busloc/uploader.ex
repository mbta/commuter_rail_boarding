defmodule Busloc.Uploader do
  @moduledoc """
  Behavior for uploading a file.

  Defines a function, `upload/1` which takes the binary file and some configuration.
  """
  @callback upload(binary, map) :: :ok
end
