defmodule HTTPClient do
  @moduledoc """
  Simple wrapper around HTTPoison and Poison"
  """
  use HTTPoison.Base
  require Logger

  def process_url(url) do
    _ =
      Logger.debug(fn ->
        "#{__MODULE__}:#{inspect(self())} requesting #{url}"
      end)

    key = Application.get_env(:commuter_rail_boarding, :v3_api_key)

    url =
      cond do
        is_nil(key) ->
          url

        String.contains?(url, "?") ->
          url <> "&api_key=" <> key

        true ->
          url <> "?api_key=" <> key
      end

    "https://api.mbtace.com" <> url
  end

  def process_response_body(body) do
    Poison.decode!(body)
  end
end
