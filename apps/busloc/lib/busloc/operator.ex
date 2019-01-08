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
end
