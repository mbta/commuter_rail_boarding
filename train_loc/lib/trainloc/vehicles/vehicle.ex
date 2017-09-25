defmodule TrainLoc.Vehicles.Vehicle do
alias TrainLoc.Vehicles.Vehicle.GPS

    defstruct [
        :vehicle_id,
        :timestamp,
        :operator,
        :block,
        :trip,
        :gps
    ]

    @type t :: %__MODULE__{
        vehicle_id: String.t | nil,
        timestamp: DateTime.t | nil,
        operator: String.t | nil,
        block: String.t | nil,
        trip: String.t | nil,
        gps: GPS.t | nil
    }

    def from_map(map) do
        %__MODULE__{
            vehicle_id: map |> Map.get(:vehicle_id, ""),
            timestamp:  map |> Map.get(:timestamp),
            operator:   map |> Map.get(:operator, ""),
            block:      map |> Map.get(:workpiece, "0"),
            trip:       map |> Map.get(:pattern, "0"),
            gps:        map |> Map.get(:gps, %{}) |> GPS.from_map
        }
    end

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
            time: non_neg_integer,
            lat: float,
            long: float,
            speed: non_neg_integer,
            heading: 0..359,
            source: 0..9,
            age: 0..2
        }

        def from_map(map) do
            %__MODULE__{
                time:    map |> Map.get(:time, 0),
                lat:     map |> Map.get(:lat, 0),
                long:    map |> Map.get(:long, 0),
                speed:   map |> Map.get(:speed, 0),
                heading: map |> Map.get(:heading, 0),
                source:  map |> Map.get(:source, 0),
                age:     map |> Map.get(:age, 0)
            }
        end
    end
end
