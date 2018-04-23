defmodule Busloc.Uploader.File do
  @moduledoc """
  Uploader which writes to a file.
  """
  @behaviour Busloc.Uploader
  require Logger

  @impl Busloc.Uploader
  def upload(binary) do
    ret = File.write!("nextbus.xml", binary, [:write, :utf8])

    Logger.info(fn ->
      "#{__MODULE__} wrote #{byte_size(binary)} bytes: #{inspect(ret)}"
    end)

    ret
  end

  @impl Busloc.Uploader
  def post_nextbus(binary) do
    binary
  end
end
