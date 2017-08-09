defmodule HTTPClient do
  @moduledoc """
  Simple wrapper around HTTPoison and Poison"
  """
  use HTTPoison.Base
  require Logger

  def process_url(url) do
    Logger.debug fn ->
      "#{__MODULE__}:#{inspect self()} requesting #{url}"
    end
    "https://api.mbtace.com" <> url
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end
end
