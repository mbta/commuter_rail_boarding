defmodule TrainLoc.Vehicles.Vehicle do
    @moduledoc """
    Struct for storing general Vehicle information
    """

    import String, only: [to_integer: 1]

    alias TrainLoc.Vehicles.Vehicle.GPS
    alias TrainLoc.Utilities.Time

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
            timestamp:  Timex.parse!(map["timestamp"], "{0M}-{0D}-{YYYY} {0h12}:{0m}:{0s} {AM}"),
            operator:   map["operator"],
            block:      map["workpiece"],
            trip:       map["pattern"],
            gps:        GPS.from_map(map)
        }
    end

    @spec log_string(t) :: String.t
    def log_string(v) do
        Time.format_datetime(v.timestamp) <> " - id:" <> v.vehicle_id <> ", block:" <> v.block <> ", trip:" <> v.trip
    end

    def active_vehicle?(%__MODULE__{operator: "0"}), do: false
    def active_vehicle?(%__MODULE__{block: "0"}), do: false
    def active_vehicle?(%__MODULE__{trip: "0"}), do: false
    def active_vehicle?(%__MODULE__{trip: "9999"}), do: false
    def active_vehicle?(%__MODULE__{}), do: true

    defmodule GPS do
        @moduledoc """
        Struct for holding vehicle GPS data
        """

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
                time:    to_integer(map["time"]),
                lat:     to_float(map["lat"]) / 100000,
                long:    to_float(map["long"]) / 100000,
                speed:   to_integer(map["speed"]),
                heading: to_integer(map["heading"]),
                source:  to_integer(map["source"]),
                age:     to_integer(map["age"])
            }
        end

        defp to_float(string) do
            string
            |> Float.parse()
            |> elem(0)
        end
    end
end
