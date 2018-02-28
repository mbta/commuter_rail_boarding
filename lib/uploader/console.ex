defmodule Uploader.Console do
  @moduledoc """
  Uploder implementation which logs the file.
  """
  @behaviour Uploader
  require Logger

  @impl true
  def upload(filename, binary) do
    Logger.info(fn -> "#{__MODULE__}.upload: #{filename} #{inspect(binary)}" end)
  end
end
