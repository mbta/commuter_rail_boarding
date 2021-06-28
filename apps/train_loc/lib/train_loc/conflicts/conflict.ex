defmodule TrainLoc.Conflicts.Conflict do
  @moduledoc """
  Functions for working with individual conflicts.

  A conflict is when multiple vehicles are assigned to the same trip or block.
  """
  alias TrainLoc.Utilities.Time
  alias TrainLoc.Vehicles.Vehicle

  defstruct [
    :assign_type,
    :assign_id,
    :vehicles,
    :service_date
  ]

  @typedoc """
  Represents a conflicting assignment.

  * `assign_type`: indicates whether the conflict is for a trip or a block
  * `assign_id`: unique ID for assignment
  * `vehicles`: vehicle IDs in conflict
  * `service_date`: date of conflict
  """
  @type t :: %__MODULE__{
          assign_type: :trip | :block,
          assign_id: String.t(),
          vehicles: [integer],
          service_date: Date.t() | Timex.Types.date()
        }

  @type field :: :assign_type | :assign_id | :vehicles | :service_date

  @spec from_tuple({String.t(), [Vehicle.t()]}, atom) :: t
  def from_tuple({assign_id, vehicles}, type) do
    %__MODULE__{
      assign_type: type,
      assign_id: assign_id,
      vehicles: Enum.map(vehicles, & &1.vehicle_id),
      service_date:
        vehicles
        |> Enum.max_by(&Timex.to_unix(&1.timestamp))
        |> Map.get(:timestamp)
        |> Time.get_service_date()
    }
  end

  @spec log_string(t) :: String.t()
  def log_string(c) do
    "#{c.service_date}: Conflict in #{c.assign_type} #{c.assign_id}. Assigned vehicles: #{Enum.join(c.vehicles, ", ")}"
  end

  def email_string(c) do
    "#{to_string(c.assign_type)} #{c.assign_id}, vehicles: #{Enum.join(c.vehicles, ", ")}"
  end
end
