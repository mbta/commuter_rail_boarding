defmodule ConfigHelpers do
  @moduledoc """
  Helper functions for working with the app configuration
  """

  @doc """
  Returns a value from the configuration.

  If the configured value is {:system, binary}, uses the value of the
  environment variable. Otherwise, uses the configured value directly.
  """
  def config(key) do
    :commuter_rail_boarding
    |> Application.get_env(key)
    |> do_config
  end

  def config(parent, key) do
    :commuter_rail_boarding
    |> Application.get_env(parent)
    |> Keyword.get(key)
    |> do_config
  end

  defp do_config({:system, envvar}) when is_binary(envvar) do
    System.get_env(envvar)
  end

  defp do_config(value) do
    value
  end
end
