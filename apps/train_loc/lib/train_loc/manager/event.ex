defmodule TrainLoc.Manager.Event do
  @moduledoc """
  Defines a struct that holds parsed and validated
  `:vehicles_json` list and a `:date` as a string or nil.
  """

  alias TrainLoc.Manager.EventJsonParser

  @type t() :: %__MODULE__{
          date: String.t() | nil,
          vehicles_json: [map()]
        }

  defstruct date: nil,
            vehicles_json: []

  @spec parse(String.t() | map) :: {:ok, t()} | {:error, any()}
  def parse(data) when is_binary(data) or is_map(data) do
    EventJsonParser.parse(data)
  end
end
