defmodule Uploader.Console do
  @behaviour Uploader
  require Logger

  @impl true
  def upload(binary) do
    Logger.info(fn -> "#{__MODULE__}.upload: #{inspect binary}" end)
  end
end
