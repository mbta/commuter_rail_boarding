defmodule TrainLoc.Manager.Event do
  @moduledoc """
  Defines a struct that holds parsed and validated
  `:vehicles_json` list and a `:date` as a string or nil.
  """

  alias TrainLoc.Manager.EventJsonParser

  defstruct [
    date: nil,
    vehicles_json: [],
  ]
  
  def from_string(string) when is_binary(string) do
    EventJsonParser.parse(string)
  end

end