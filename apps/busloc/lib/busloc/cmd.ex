defmodule Busloc.Cmd do
  @moduledoc """
  Behavior to represent getting SQL data as a string.
  """

  @callback can_connect?() :: boolean
  @callback operator_cmd() :: String.t()
  @callback shuttle_cmd() :: String.t()
  @callback assigned_logon_cmd() :: String.t()
end
