defmodule Busloc.Uploader.Nextbus do
  @moduledoc """
  Uploader which writes the file to Nextbus.
  """
  @behaviour Busloc.Uploader
  require Logger

  @impl Busloc.Uploader
  def upload(binary, config) do
    case HTTPoison.post(config.url, binary, [], hackney: [pool: :default]) do
      {:ok, response} ->
        Logger.debug(fn -> "Posted to #{config.url} response=#{response.body}" end)

      {:error, reason} ->
        Logger.error(fn -> "Unable to post to #{config.url}: reason=#{inspect(reason)}" end)
    end

    :ok
  end
end
