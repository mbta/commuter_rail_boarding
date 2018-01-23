defmodule TrainLoc.Assignments.AssignmentsTest do

  use ExUnit.Case, async: true

  alias TrainLoc.Assignments.Assignment
  alias TrainLoc.Assignments.Assignments
  alias TrainLoc.Vehicles.Vehicle

  setup do
    vehicles = %{
      v1_b1_t1: %Vehicle{
        vehicle_id: 1111,
        timestamp: ~N[2017-08-04 11:00:00],
        block: "1",
        trip: "1",
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 0,
        heading: 188,
        fix: 1
      },
      v1_b1_t2: %Vehicle{
        vehicle_id: 1111,
        timestamp: ~N[2017-08-04 12:00:00],
        block: "1",
        trip: "2",
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 0,
        heading: 188,
        fix: 1
      },
      v1_b1_t3: %Vehicle{
        vehicle_id: 1111,
        timestamp: ~N[2017-08-04 13:00:00],
        block: "1",
        trip: "3",
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 0,
        heading: 188,
        fix: 1
      }
    }
    assigns = %{
      assign1: %Assignment{
        service_date: ~D[2017-08-04],
        vehicle_id: 1111,
        block: "1",
        trip: "1"
      },
      assign2: %Assignment{
        service_date: ~D[2017-08-04],
        vehicle_id: 1111,
        block: "1",
        trip: "2"
      },
      assign3: %Assignment{
        service_date: ~D[2017-08-04],
        vehicle_id: 1111,
        block: "1",
        trip: "3"
      },
      assign4: %Assignment{
        service_date: ~D[2017-08-04],
        vehicle_id: 1111,
        block: "2",
        trip: "4"
      },
      assign5: %Assignment{
        service_date: ~D[2017-08-04],
        vehicle_id: 1111,
        block: "2",
        trip: "5"
      },
      assign6: %Assignment{
        service_date: ~D[2017-08-04],
        vehicle_id: 2222,
        block: "3",
        trip: "6"
      },
      assign7: %Assignment{
        service_date: ~D[2017-08-05],
        vehicle_id: 1111,
        block: "1",
        trip: "1"
      },
      assign8: %Assignment{
        service_date: ~D[2017-08-04],
        vehicle_id: 2222,
        block: "1",
        trip: "1"
      },
      assign9: %Assignment{
        service_date: ~D[2017-08-04],
        vehicle_id: 2222,
        block: "1",
        trip: "7"
      }
    }
    %{vehicles: vehicles, assigns: assigns}
  end

  test "adds vehicle assignments", %{vehicles: test_vehicles, assigns: test_assigns} do
    assigns = Assignments.new()
      |> Assignments.add(test_vehicles.v1_b1_t1)
      |> Assignments.add(test_vehicles.v1_b1_t2)
      |> Assignments.add(test_vehicles.v1_b1_t3)
      |> Assignments.add(test_vehicles.v1_b1_t1)

    assert Assignments.member?(assigns, test_assigns.assign1)
    assert Assignments.member?(assigns, test_assigns.assign2)
    assert Assignments.member?(assigns, test_assigns.assign3)
  end

  test "batch adds vehicle assignments", %{vehicles: test_vehicles, assigns: test_assigns} do
    assigns = Assignments.add(Assignments.new(), Map.values(test_vehicles))

    assert Assignments.member?(assigns, test_assigns.assign1)
    assert Assignments.member?(assigns, test_assigns.assign2)
    assert Assignments.member?(assigns, test_assigns.assign3)
  end

  test "aggregates vehicle assignments", %{assigns: test_assigns} do
    assigns = test_assigns
      |> Map.values()
      |> Assignments.new()

    grouped_by_block_and_vehicle = Assignments.group_by_block_vehicle(assigns)
    assert grouped_by_block_and_vehicle == %{
      {~D[2017-08-04], "1"} => %{
        1111 => ["1", "2", "3"],
        2222 => ["1", "7"]
      },
      {~D[2017-08-04], "2"} => %{
        1111 => ["4", "5"]
      },
      {~D[2017-08-04], "3"} => %{
        2222 => ["6"]
      },
      {~D[2017-08-05], "1"} => %{
        1111 => ["1"]
      }
    }

    grouped_by_vehicle_and_block = Assignments.group_by_vehicle_block(assigns)
    assert grouped_by_vehicle_and_block == %{
      {~D[2017-08-04], 1111} => %{
        "1" => ["1", "2", "3"],
        "2" => ["4", "5"]
      },
      {~D[2017-08-04], 2222} => %{
        "1" => ["1", "7"],
        "3" => ["6"]
      },
      {~D[2017-08-05], 1111} => %{
        "1" => ["1"]
      }
    }

    grouped_by_block = Assignments.group_by_block(assigns)
    assert grouped_by_block == %{
      {~D[2017-08-04], "1"} => ["1", "2", "3", "7"],
      {~D[2017-08-04], "2"} => ["4", "5"],
      {~D[2017-08-04], "3"} => ["6"],
      {~D[2017-08-05], "1"} => ["1"]
    }

    grouped_by_vehicle = Assignments.group_by_vehicle(assigns)
    assert grouped_by_vehicle == %{
      {~D[2017-08-04], 1111} => ["1", "2", "3", "4", "5"],
      {~D[2017-08-04], 2222} => ["1", "7", "6"],
      {~D[2017-08-05], 1111} => ["1"]
    }
  end
end
