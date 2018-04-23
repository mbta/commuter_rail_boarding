defmodule Busloc.Uploader.Nextbus do
  @moduledoc """
  Uploader which writes the file to Nextbus.
  """
  @behaviour Busloc.Uploader
  import Busloc.Utilities.ConfigHelpers
  require Logger

  @impl Busloc.Uploader
  def upload(binary) do
    nextbus_url = config(Uploader.Nextbus, :nextbus_url)

    case HTTPoison.post(nextbus_url, binary) do
      {:ok, response} ->
        Logger.debug(fn -> "Posted to #{nextbus_url} response=#{response.body}" end)

      {:error, reason} ->
        Logger.error(fn -> "Unable to post to Nextbus: reason=#{reason}" end)
    end

    :ok
  end
end
