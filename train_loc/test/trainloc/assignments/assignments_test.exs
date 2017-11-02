defmodule TrainLoc.Assignments.AssignmentsTest do
    use ExUnit.Case, async: true
    alias TrainLoc.Assignments.Assignment
    alias TrainLoc.Assignments.Assignments
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Vehicles.Vehicle.GPS
    doctest Assignments

    @date1 ~D[2017-08-04]
    @date2 ~D[2017-08-05]

    @v1_b1_t1 %Vehicle{
        vehicle_id: "1111",
        timestamp: ~N[2017-08-04 11:00:00],
        operator: "910",
        block: "1",
        trip: "1",
        gps: %GPS{
            time: 54109,
            lat: 42.24023,
            long: -71.12890,
            speed: 0,
            heading: 188,
            source: 1,
            age: 2
        }
    }
    @assign1 %Assignment{
        service_date: @date1,
        vehicle_id: "1111",
        block: "1",
        trip: "1"
    }
    @v1_b1_t2 %Vehicle{
        vehicle_id: "1111",
        timestamp: ~N[2017-08-04 12:00:00],
        operator: "910",
        block: "1",
        trip: "2",
        gps: %GPS{
            time: 54109,
            lat: 42.24023,
            long: -71.12890,
            speed: 0,
            heading: 188,
            source: 1,
            age: 2
        }
    }
    @assign2 %Assignment{
        service_date: @date1,
        vehicle_id: "1111",
        block: "1",
        trip: "2"
    }
    @v1_b1_t3 %Vehicle{
        vehicle_id: "1111",
        timestamp: ~N[2017-08-04 13:00:00],
        operator: "910",
        block: "1",
        trip: "3",
        gps: %GPS{
            time: 54109,
            lat: 42.24023,
            long: -71.12890,
            speed: 0,
            heading: 188,
            source: 1,
            age: 2
        }
    }
    @assign3 %Assignment{
        service_date: @date1,
        vehicle_id: "1111",
        block: "1",
        trip: "3"
    }
    @v1_b2_t4 %Vehicle{
        vehicle_id: "1111",
        timestamp: ~N[2017-08-04 14:00:00],
        operator: "910",
        block: "2",
        trip: "4",
        gps: %GPS{
            time: 54109,
            lat: 42.24023,
            long: -71.12890,
            speed: 0,
            heading: 188,
            source: 1,
            age: 2
        }
    }
    @assign4 %Assignment{
        service_date: @date1,
        vehicle_id: "1111",
        block: "2",
        trip: "4"
    }
    @assign5 %Assignment{
        service_date: @date1,
        vehicle_id: "1111",
        block: "2",
        trip: "5"
    }
    @assign6 %Assignment{
        service_date: @date1,
        vehicle_id: "2222",
        block: "3",
        trip: "6"
    }
    @assign7 %Assignment{
        service_date: @date2,
        vehicle_id: "1111",
        block: "1",
        trip: "1"
    }
    @assign8 %Assignment{
        service_date: @date1,
        vehicle_id: "2222",
        block: "1",
        trip: "1"
    }
    @assign9 %Assignment{
        service_date: @date1,
        vehicle_id: "2222",
        block: "1",
        trip: "7"
    }

    test "adds vehicle assignments" do
        assigns = MapSet.new()

        assigns = Assignments.add(assigns, @v1_b1_t1) |>
            Assignments.add(@v1_b1_t2) |>
            Assignments.add(@v1_b1_t3) |>
            Assignments.add(@v1_b2_t4) |>
            Assignments.add(@v1_b1_t1)

        assert MapSet.equal?(assigns, MapSet.new([@assign1, @assign2, @assign3, @assign4]))
    end

    test "aggregates vehicle assignments" do
        assigns = MapSet.new([@assign1, @assign2, @assign3, @assign4, @assign5, @assign6, @assign7, @assign8, @assign9])

        grouped_by_block_and_vehicle = Assignments.group_by_block_vehicle(assigns)
        assert grouped_by_block_and_vehicle == %{
            {@date1, "1"} => %{
                "1111" => ["1", "2", "3"],
                "2222" => ["1", "7"]
            },
            {@date1, "2"} => %{
                "1111" => ["4", "5"]
            },
            {@date1, "3"} => %{
                "2222" => ["6"]
            },
            {@date2, "1"} => %{
                "1111" => ["1"]
            }
        }

        grouped_by_vehicle_and_block = Assignments.group_by_vehicle_block(assigns)
        assert grouped_by_vehicle_and_block == %{
            {@date1, "1111"} => %{
                "1" => ["1", "2", "3"],
                "2" => ["4", "5"]
            },
            {@date1, "2222"} => %{
                "1" => ["1", "7"],
                "3" => ["6"]
            },
            {@date2, "1111"} => %{
                "1" => ["1"]
            }
        }

        grouped_by_block = Assignments.group_by_block(assigns)
        assert grouped_by_block == %{
            {@date1, "1"} => ["1", "2", "3", "7"],
            {@date1, "2"} => ["4", "5"],
            {@date1, "3"} => ["6"],
            {@date2, "1"} => ["1"]
        }

        grouped_by_vehicle = Assignments.group_by_vehicle(assigns)
        assert grouped_by_vehicle == %{
            {@date1, "1111"} => ["1", "2", "3", "4", "5"],
            {@date1, "2222"} => ["1", "7", "6"],
            {@date2, "1111"} => ["1"]
        }
    end

end
