defmodule Busloc.Utilities.ConfigHelpers do
  @moduledoc """
  Helper functions for working with the app configuration
  """

  @doc """
  Returns a value from the configuration.

  If the configured value is {:system, binary}, uses the value of the
  environment variable. Otherwise, uses the configured value directly.
  """
  def config(key) do
    :busloc
    |> Application.get_env(key)
    |> interpolate
  end

  def config(parent, key) do
    :busloc
    |> Application.get_env(parent)
    |> Keyword.get(key)
    |> interpolate
  end

  def interpolate({:system, envvar}) when is_binary(envvar) do
    System.get_env(envvar)
  end

  def interpolate(value) do
    value
  end
end
