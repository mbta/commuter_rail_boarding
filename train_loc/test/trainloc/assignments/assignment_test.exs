defmodule TrainLoc.Assignments.AssignmentTest do
    use ExUnit.Case, async: true
    alias TrainLoc.Assignments.Assignment
    alias TrainLoc.Vehicles.Vehicle
    doctest Assignment

    test "extracts data from Vehicle to create Assignment struct" do
        vehicle = %Vehicle{
            vehicle_id: "1111",
            timestamp: ~N[2017-08-04 11:00:00],
            operator: "910",
            block: "1",
            trip: "1",
            gps: nil
        }

        assert Assignment.from_vehicle(vehicle) == %Assignment{
            service_date: ~D[2017-08-04],
            vehicle_id: "1111",
            block: "1",
            trip: "1"
        }
    end

end
