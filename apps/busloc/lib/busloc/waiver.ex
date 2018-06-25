defmodule Busloc.Waiver do
  @moduledoc """
  Represents an change to scheduled service.

  Waivers are entered by a dispatcher into TransitMaster, along with some
  flags.
  """
  defstruct [
    :route_id,
    :trip_id,
    :stop_id,
    :block_id,
    :updated_at,
    :remark,
    :early_allowed?,
    :late_allowed?,
    :missed_allowed?,
    :no_revenue?
  ]

  @type t :: %__MODULE__{
          route_id: String.t(),
          trip_id: String.t(),
          stop_id: String.t(),
          block_id: String.t(),
          updated_at: DateTime.t(),
          remark: remark,
          early_allowed?: boolean,
          late_allowed?: boolean,
          missed_allowed?: boolean,
          no_revenue?: boolean
        }

  @typedoc """
  B – Manpower
  C – No Equipment
  D – Disabled Bus
  E – Diverted to other work
  F – Traffic
  G – Accident
  H – Weather
  I – Operator Error
  J - Other

  Typed out from memory by dispatch supervisor Mike Joyce
  """
  @type remark :: String.t()

  defdelegate log_line(waiver), to: Busloc.LogHelper, as: :log_struct
end
