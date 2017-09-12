defmodule TrainLoc.Conflicts.Conflict do
    alias TrainLoc.Vehicles.Vehicle

    defstruct [
        :assign_type, #"p" for pattern OR "w" for workpiece
        :assign_id,
        :vehicles,
        :service_date
    ]

    @type t :: %__MODULE__{
        assign_type: :pattern | :workpiece | nil,
        assign_id: String.t | nil,
        vehicles: [String.t],
        service_date: DateTime.t
    }

    @type field :: :assign_type | :assign_id | :vehicles | :service_date

    @spec from_tuple({String.t, [Vehicle.t]}, String.t) :: t
    def from_tuple(tuple, type) do
        vehicles = elem(tuple, 1)
        %__MODULE__{
            assign_type: type,
            assign_id: elem(tuple, 0),
            vehicles: vehicles |> Enum.map(& &1.vehicle_id),
            service_date: vehicles |> Enum.reduce(Timex.epoch, fn(v, acc) -> max(acc, v.timestamp) end) |> Timex.to_date
        }
    end
end
