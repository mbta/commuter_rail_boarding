defmodule TrainLoc.Assignments.AssignmentTest do
  use ExUnit.Case, async: true

  alias TrainLoc.Assignments.Assignment
  alias TrainLoc.Vehicles.Vehicle

  test "extracts data from Vehicle to create Assignment struct" do
    vehicle = %Vehicle{
      vehicle_id: 1111,
      timestamp: ~N[2017-08-04 11:00:00],
      block: "1",
      trip: "1",
      latitude: 42.24023,
      longitude: -71.12890,
      speed: 0,
      heading: 188,
      fix: 1
    }

    assert Assignment.from_vehicle(vehicle) == %Assignment{
      service_date: ~D[2017-08-04],
      vehicle_id: 1111,
      block: "1",
      trip: "1"
    }
  end
end
