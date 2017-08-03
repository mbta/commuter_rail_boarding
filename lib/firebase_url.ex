defmodule FirebaseUrl do
  @moduledoc """
  Builds the URL to get data out of Firebase.

  Requires Goth to be configured properly in order to calculate the token.
  """
  alias Goth.Token

  def url do
    url(token_fn: &goth_token/0)
  end

  def url([token_fn: token_fn]) do
    uri = URI.parse(config(:firebase_url))
    uri = %{uri | query: merge_query(uri.query, "access_token=#{token_fn.()}")}
    URI.to_string(uri)
  end

  defp merge_query(nil, query), do: query
  defp merge_query("", query), do: query
  defp merge_query(first, second), do: first <> "&" <> second

  defp config(key) do
    case Application.get_env(:commuter_rail_boarding, key) do
      {:system, envvar} -> System.get_env(envvar)
      value -> value
    end
  end

  defp goth_token do
    scopes = Enum.join([
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/userinfo.email"], " ")
    {:ok, token} = Token.for_scope(scopes)
    token.token
  end
end
