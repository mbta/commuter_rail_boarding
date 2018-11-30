defmodule Busloc.Uploader.File do
  @moduledoc """
  Uploader which writes to a file.
  """
  @behaviour Busloc.Uploader
  require Logger

  @impl Busloc.Uploader
  def upload(binary, config) do
    ret = File.write!(config.filename, binary, [:write, :utf8])

    Logger.debug(fn ->
      "#{__MODULE__} wrote #{byte_size(binary)} bytes to #{config.filename}: #{inspect(ret)}"
    end)

    ret
  end
end
