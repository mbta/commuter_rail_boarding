defmodule TrainLoc.Manager.Event do
  alias TrainLoc.Manager.EventJsonParser

  defstruct [
    date: nil,
    vehicles_json: [],
  ]
  
  def from_string(string) when is_binary(string) do
    EventJsonParser.parse(string)
  end

end