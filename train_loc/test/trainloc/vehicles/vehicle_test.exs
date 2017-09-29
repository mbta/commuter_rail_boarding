defmodule TrainLoc.Vehicles.VehicleTest do
    use ExUnit.Case, async: true
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Vehicles.Vehicle.GPS
    doctest Vehicle

    test "converts parse result map to Vehicle struct" do
        map = %{
            "vehicle_id" => "1625",
            "timestamp" => "08-04-2017 11:01:48 AM",
            "type" => "Location",
            "operator" => "0",
            "workpiece" => "0",
            "pattern" => "0",
            "time" => "54106",
            "lat" => "+4237434",
            "long" => "-07107818",
            "speed" => "000",
            "heading" => "280",
            "source" => "1",
            "age" => "2"
        }

        assert Vehicle.from_map(map) == %Vehicle{
            vehicle_id: "1625",
            timestamp: ~N[2017-08-04 11:01:48],
            operator: "0",
            block: "0",
            trip: "0",
            gps: %GPS{
                time: 54106,
                lat: 42.37434,
                long: -71.07818,
                speed: 0,
                heading: 280,
                source: 1,
                age: 2
            }
        }
    end
end
