defmodule TrainLoc.Conflicts.Conflict do
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Utilities.Time

    defstruct [
        :assign_type,
        :assign_id,
        :vehicles,
        :service_date
    ]

    @type t :: %__MODULE__{
        assign_type: :trip | :block | nil,
        assign_id: String.t | nil,
        vehicles: [String.t],
        service_date: Date.t | Timex.Types.date
    }

    @type field :: :assign_type | :assign_id | :vehicles | :service_date

    @spec from_tuple({String.t, [Vehicle.t]}, atom) :: t
    def from_tuple(tuple, type) do
        vehicles = elem(tuple, 1)
        %__MODULE__{
            assign_type: type,
            assign_id: elem(tuple, 0),
            vehicles: vehicles |> Enum.map(& &1.vehicle_id),
            service_date: vehicles |> Enum.reduce(Timex.epoch, fn(v, acc) -> max(acc, v.timestamp) end) |> Time.get_service_date
        }
    end

    @spec conflict_string(t) :: String.t
    def conflict_string(c) do
        to_string(c.service_date)<>": Conflict in "<>to_string(c.assign_type)<>" "<>c.assign_id<>". Assigned vehicles: "<>Enum.join(c.vehicles, ", ")
    end
end
