defmodule Busloc.Operator do
  @moduledoc """
  Represents an operator's scheduled work.
  """
  defstruct [
    :vehicle_id,
    :operator_name,
    :operator_id,
    :block,
    :run
  ]

  @type t :: %__MODULE__{
          vehicle_id: String.t(),
          operator_name: String.t() | nil,
          operator_id: String.t() | nil,
          block: String.t(),
          run: String.t() | nil
        }

  defdelegate log_line(operator), to: Busloc.LogHelper, as: :log_struct

  @spec from_map(map) :: [t()]
  def from_map(%{
        "vehicle_id" => vehicle_id,
        "block_id" => block_id,
        "operator_name" => operator_name,
        "operator_id" => operator_id,
        "run_id" => run_id
      }) do
    [
      %__MODULE__{
        vehicle_id: vehicle_id,
        operator_name: operator_name,
        operator_id: operator_id,
        block: block_id,
        run: run_id
      }
    ]
  end

  def from_map(_), do: []
end
