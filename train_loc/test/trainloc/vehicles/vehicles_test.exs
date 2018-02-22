defmodule TrainLoc.Vehicles.VehiclesTest do

  use ExUnit.Case, async: true

  alias TrainLoc.Vehicles.Vehicles
  alias TrainLoc.Vehicles.Vehicle
  alias TrainLoc.Conflicts.Conflict

  import ExUnit.CaptureLog
  require Logger

  setup do
    vehicles = %{
      vehicle1: %Vehicle{
        vehicle_id: 1712,
        timestamp: ~N[2017-08-04 11:01:51],
        block: "802",
        trip: "509",
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 0,
        heading: 188,
        fix: 1
      },
      vehicle2: %Vehicle{
        vehicle_id: 1713,
        timestamp: ~N[2017-08-04 11:01:51],
        block: "803",
        trip: "508",
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 7,
        heading: 188,
        fix: 1
      },
      vehicle3: %Vehicle{
        vehicle_id: 1714,
        timestamp: ~N[2017-08-04 11:01:51],
        block: "803",
        trip: "508",
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 000,
        heading: 188,
        fix: 1
      },
      vehicle4: %Vehicle{
        vehicle_id: 1715,
        timestamp: ~N[2017-08-04 11:01:51],
        block: "802",
        trip: "510",
        latitude: 42.24023,
        longitude: -071.12890,
        speed: 000,
        heading: 188,
        fix: 1
      }
    }
    conflicts = [
        %Conflict{
            assign_type: :trip,
            assign_id: "508",
            vehicles: [1713, 1714],
            service_date: ~D[2017-08-04]
        },
        %Conflict{
            assign_type: :block,
            assign_id: "802",
            vehicles: [1712, 1715],
            service_date: ~D[2017-08-04]
        },
        %Conflict{
            assign_type: :block,
            assign_id: "803",
            vehicles: [1713, 1714],
            service_date: ~D[2017-08-04]
        }
    ]
    %{vehicles: vehicles, conflicts: conflicts}
  end

  test "Stores and deletes train vehicles", %{vehicles: test_vehicles} do
    test_vehicle = test_vehicles.vehicle1
    test_id = test_vehicle.vehicle_id

    vehicles = Vehicles.new()
    assert Vehicles.get(vehicles, test_id) == nil

    vehicles = Vehicles.put(vehicles, test_vehicle)
    assert Vehicles.get(vehicles, test_id) == test_vehicle

    vehicles = Vehicles.delete(vehicles, test_id)
    assert Vehicles.get(vehicles, test_id) == nil
  end

  test "upsert/2 updates or inserts vehicles", %{vehicles: test_vehicles} do
    vehicles_list = Map.values(test_vehicles)

    vehicles = Vehicles.upsert(Vehicles.new(), vehicles_list)

    assert Vehicles.get(vehicles, test_vehicles.vehicle1.vehicle_id) == test_vehicles.vehicle1
    assert Vehicles.get(vehicles, test_vehicles.vehicle2.vehicle_id) == test_vehicles.vehicle2
    assert Vehicles.get(vehicles, test_vehicles.vehicle3.vehicle_id) == test_vehicles.vehicle3
    assert Vehicles.get(vehicles, test_vehicles.vehicle4.vehicle_id) == test_vehicles.vehicle4
  end

  test "Identifies duplicate logins", %{vehicles: test_vehicles, conflicts: test_conflicts} do
      #Same Trip: vehicle_two & vehicle_three
      #Same Block: vehicle_one & vehicle_four; vehicle_two & vehicle_three
      vehicles = test_vehicles
        |> Map.values()
        |> Vehicles.new()

      assert Vehicles.find_duplicate_logons(vehicles) == test_conflicts
  end

  describe "log_assignments/1" do
    test "with list of valid vehicles", %{vehicles: test_vehicles} do
      vehicles = Map.values(test_vehicles)
      fun = fn -> Vehicles.log_assignments(vehicles) end

      expected_logger_messages =
        for vehicle <- vehicles do
            "Vehicle Assignment - "
            <> "id=#{inspect vehicle.vehicle_id} "
            <> "trip=#{inspect vehicle.trip} "
            <> "block=#{inspect vehicle.block}"
        end

      captured_logger_messages = capture_log(fun)
      for expected_logger_message <- expected_logger_messages do
        assert captured_logger_messages =~ expected_logger_message
      end
    end
  end
end
