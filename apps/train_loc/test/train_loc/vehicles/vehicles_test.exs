defmodule TrainLoc.Vehicles.VehiclesTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias TrainLoc.Conflicts.Conflict
  alias TrainLoc.Vehicles.Vehicle
  alias TrainLoc.Vehicles.Vehicles

  setup do
    iso_8601 = "2017-08-04T11:01:51Z"
    {:ok, datetime, 0} = DateTime.from_iso8601(iso_8601)

    vehicles = %{
      vehicle1: %Vehicle{
        vehicle_id: 1712,
        timestamp: datetime,
        block: 802,
        trip: 509,
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 0,
        heading: 188
      },
      vehicle2: %Vehicle{
        vehicle_id: 1713,
        timestamp: datetime,
        block: 803,
        trip: 508,
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 7,
        heading: 188
      },
      vehicle3: %Vehicle{
        vehicle_id: 1714,
        timestamp: datetime,
        block: 803,
        trip: 508,
        latitude: 42.24023,
        longitude: -71.12890,
        speed: 000,
        heading: 188
      },
      vehicle4: %Vehicle{
        vehicle_id: 1715,
        timestamp: datetime,
        block: 802,
        trip: 510,
        latitude: 42.24023,
        longitude: -071.12890,
        speed: 000,
        heading: 188
      }
    }

    conflicts = [
      %Conflict{
        assign_type: :trip,
        assign_id: 508,
        vehicles: [1713, 1714],
        service_date: ~D[2017-08-04]
      },
      %Conflict{
        assign_type: :block,
        assign_id: 802,
        vehicles: [1712, 1715],
        service_date: ~D[2017-08-04]
      },
      %Conflict{
        assign_type: :block,
        assign_id: 803,
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

    assert Vehicles.get(vehicles, test_vehicles.vehicle1.vehicle_id) ==
             test_vehicles.vehicle1

    assert Vehicles.get(vehicles, test_vehicles.vehicle2.vehicle_id) ==
             test_vehicles.vehicle2

    assert Vehicles.get(vehicles, test_vehicles.vehicle3.vehicle_id) ==
             test_vehicles.vehicle3

    assert Vehicles.get(vehicles, test_vehicles.vehicle4.vehicle_id) ==
             test_vehicles.vehicle4
  end

  test "Identifies duplicate logins", %{
    vehicles: test_vehicles,
    conflicts: test_conflicts
  } do
    # Same Trip: vehicle_two & vehicle_three
    # Same Block: vehicle_one & vehicle_four; vehicle_two & vehicle_three
    vehicles =
      test_vehicles
      |> Map.values()
      |> Vehicles.new()

    assert Vehicles.find_duplicate_logons(vehicles) == test_conflicts
  end
end
