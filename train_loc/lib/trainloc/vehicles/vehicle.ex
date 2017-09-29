defmodule TrainLoc.Vehicles.Vehicle do
alias TrainLoc.Vehicles.Vehicle.GPS

    @enforce_keys [:vehicle_id]
    defstruct [
        :vehicle_id,
        timestamp: ~N[1970-01-01 00:00:00],
        operator: "910",
        block: "0",
        trip: "0",
        gps: nil
    ]

    @type t :: %__MODULE__{
        vehicle_id: String.t,
        timestamp: DateTime.t,
        operator: String.t,
        block: String.t,
        trip: String.t,
        gps: GPS.t | nil
    }

    def from_map(map) do
        %__MODULE__{
            vehicle_id: map["vehicle_id"],
            timestamp:  map["timestamp"] |> Timex.parse!("{0M}-{0D}-{YYYY} {0h12}:{0m}:{0s} {AM}"),
            operator:   map["operator"],
            block:      map["workpiece"],
            trip:       map["pattern"],
            gps:        GPS.from_map(map)
        }
    end

    defmodule GPS do

        defstruct [
            time: 0,
            lat: 0.0,
            long: 0.0,
            speed: 0,
            heading: 0,
            source: 0,
            age: 0
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
                time:    map["time"] |> String.to_integer,
                lat:    (map["lat"] |> Float.parse |> elem(0)) / 100000,
                long:   (map["long"] |> Float.parse |> elem(0)) / 100000,
                speed:   map["speed"] |> String.to_integer,
                heading: map["heading"] |> String.to_integer,
                source:  map["source"] |> String.to_integer,
                age:     map["age"] |> String.to_integer
            }
        end
    end
end
