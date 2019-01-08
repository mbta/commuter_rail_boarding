defmodule Busloc.Cmd do
  @moduledoc """
  Behavior to represent getting SQL data as a string.
  """

  @callback can_connect?() :: boolean
  @callback cmd() :: String.t()
end
