defmodule Busloc.Encoder do
  @moduledoc """
  Behavior to turn a list of Vehicles into a binary.
  """
  @callback encode([Busloc.Vehicle.t()]) :: binary
end
