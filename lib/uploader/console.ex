defmodule Uploader.Console do
  @moduledoc """
  Uploder implementation which logs the file.
  """
  @behaviour Uploader
  require Logger

  @impl true
  def upload(binary) do
    Logger.info(fn -> "#{__MODULE__}.upload: #{inspect binary}" end)
  end
end
