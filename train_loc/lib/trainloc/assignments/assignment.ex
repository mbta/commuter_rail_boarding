defmodule TrainLoc.Assignments.Assignment do
    @moduledoc """
    Struct for storing historical vehicle assignment data
    """

    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Utilities.Time

    defstruct [
        :service_date,
        :vehicle_id,
        :block,
        :trip
    ]

    @type t :: %__MODULE__{
        service_date: Date.t,
        vehicle_id: String.t,
        block: String.t,
        trip: String.t
    }

    @spec from_vehicle(Vehicle.t) :: Assignment.t
    def from_vehicle(vehicle) do
        %__MODULE__{
            service_date: Time.get_service_date(vehicle.timestamp),
            vehicle_id: vehicle.vehicle_id,
            block: vehicle.block,
            trip: vehicle.trip
        }
    end

    @spec from_csv(String.t) :: t
    def from_csv(csv) do
        [service_date, vehicle_id, block, trip] = String.split(csv, ",")
        %__MODULE__{
            service_date: Time.parse_date(service_date),
            vehicle_id: vehicle_id,
            block: block,
            trip: trip
        }
    end

    @spec to_csv(t) :: String.t
    def to_csv(a) do
        Time.format_date(a.service_date) <> "," <> a.vehicle_id <> "," <> a.block <> "," <> a.trip
    end
end
