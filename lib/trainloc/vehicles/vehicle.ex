defmodule TrainLoc.Vehicles.Vehicle do

    defstruct [
        :vehicle_id,
        :timestamp,
        :type,
        :operator,
        :workpiece,
        :pattern,
        :gps
    ]

    @type t :: %__MODULE__{
        vehicle_id: String.t | nil,
        timestamp: DateTime.t | nil,
        type: String.t | nil,
        operator: String.t | nil,
        workpiece: String.t | nil,
        pattern: String.t | nil,
        gps: GPS.t | nil
    }

    defmodule GPS do

        defstruct [
            :time,
            :lat,
            :long,
            :speed,
            :heading,
            :source,
            :age
        ]

        @type t :: %__MODULE__{
            time: String.t | nil,
            lat: String.t | nil,
            long: String.t | nil,
            speed: String.t | nil,
            heading: String.t | nil,
            source: String.t | nil,
            age: String.t | nil
        }

    end
end
