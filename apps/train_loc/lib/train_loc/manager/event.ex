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

  @spec from_string(String.t()) :: {:ok, t()} | {:error, any()}
  def from_string(string) when is_binary(string) do
    EventJsonParser.parse(string)
  end
end
