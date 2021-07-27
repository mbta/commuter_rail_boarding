defmodule HTTPClient do
  @moduledoc """
  Simple wrapper around HTTPoison and Poison"
  """
  use HTTPoison.Base
  require Logger

  def process_request_url(path) do
    _ =
      Logger.debug(fn ->
        "#{__MODULE__}:#{inspect(self())} requesting #{path}"
      end)

    key = Application.get_env(:commuter_rail_boarding, :v3_api_key)
    url = Application.get_env(:commuter_rail_boarding, :v3_api_url)

    path =
      cond do
        is_nil(key) ->
          path

        String.contains?(path, "?") ->
          path <> "&api_key=" <> key

        true ->
          path <> "?api_key=" <> key
      end

    url <> path
  end

  def process_response_body(body) do
    Jason.decode!(body, strings: :copy)
  end
end
