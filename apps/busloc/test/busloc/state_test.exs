defmodule Busloc.StateTest do
  use ExUnit.Case, async: true
  alias Busloc.Vehicle
  alias Busloc.AssignedLogon
  import Busloc.State
  import Busloc.Utilities.ConfigHelpers
  alias Busloc.Utilities.Time, as: BuslocTime

  describe "update_location/2" do
    setup do
      start_supervised!({Busloc.State, name: :update_location_table})
      :ok
    end

    test "Stores and retrieves single vehicle" do
      vehicle = %Vehicle{
        vehicle_id: "1234",
        block: nil,
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :samsara,
        timestamp: DateTime.utc_now()
      }

      update_location(:update_location_table, vehicle)
      from_state = get_all(:update_location_table)
      assert from_state == [vehicle]
    end

    test "updates existing vehicle if timestamp is newer" do
      timestamp = DateTime.utc_now()

      vehicle1 = %Vehicle{
        vehicle_id: "1234",
        block: "A123-456",
        run: "123-1001",
        route: "123",
        trip: "456",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        operator_id: "oper",
        operator_name: "oper name",
        timestamp: timestamp
      }

      vehicle2 = %Vehicle{
        vehicle_id: "1234",
        latitude: 42.456,
        longitude: -71.98,
        heading: 90,
        source: :samsara,
        timestamp: Timex.shift(timestamp, minutes: 1)
      }

      update_location(:update_location_table, vehicle1)
      update_location(:update_location_table, vehicle2)
      state = get_all(:update_location_table)

      assert state == [
               %{
                 vehicle2
                 | route: "123",
                   trip: "456",
                   block: "A123-456",
                   run: "123-1001",
                   operator_id: "oper",
                   operator_name: "oper name"
               }
             ]
    end

    test "doesn't update if the timestamp is older" do
      timestamp = DateTime.utc_now()

      vehicle1 = %Vehicle{
        vehicle_id: "1234",
        block: "A123-456",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        timestamp: timestamp
      }

      vehicle2 = %Vehicle{
        vehicle_id: "1234",
        block: nil,
        latitude: 42.456,
        longitude: -71.98,
        heading: 90,
        source: :samsara,
        timestamp: Timex.shift(timestamp, minutes: -1)
      }

      update_location(:update_location_table, vehicle1)
      update_location(:update_location_table, vehicle2)
      state = get_all(:update_location_table)
      assert state == [vehicle1]
    end

    test "doesn't update location if new lat/long are nil" do
      timestamp = DateTime.utc_now()

      vehicle1 = %Vehicle{
        vehicle_id: "1234",
        block: "A123-456",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        timestamp: timestamp
      }

      vehicle2 = %Vehicle{
        vehicle_id: "1234",
        block: nil,
        latitude: nil,
        longitude: nil,
        heading: 90,
        source: :samsara,
        timestamp: Timex.shift(timestamp, minutes: 1)
      }

      update_location(:update_location_table, vehicle1)
      update_location(:update_location_table, vehicle2)
      state = get_all(:update_location_table)
      assert state == [vehicle1]
    end
  end

  describe "update_assigned_logon/2" do
    setup do
      start_supervised!({Busloc.State, name: :update_assigned_logon_table})
      :ok
    end

    test "Stores single assigned logon" do
      assigned_logon = %AssignedLogon{
        vehicle_id: "2468",
        operator_name: "ASSIGNEDDRIVER1",
        operator_id: "41414",
        block: "T77-135",
        run: "101-2002"
      }

      update_assigned_logon(:update_assigned_logon_table, assigned_logon)
      from_state = get_all(:update_assigned_logon_table)

      new_vehicle = List.first(from_state)

      assert new_vehicle.block == "T77-135"
      assert new_vehicle.heading == nil
      assert new_vehicle.latitude == nil
      assert new_vehicle.longitude == nil
      assert new_vehicle.operator_id == "41414"
      assert new_vehicle.operator_name == "ASSIGNEDDRIVER1"
      assert new_vehicle.route == nil
      assert new_vehicle.run == "101-2002"
      assert new_vehicle.source == nil
      assert new_vehicle.speed == nil
      assert new_vehicle.start_date == nil
      assert new_vehicle.trip == nil
      assert new_vehicle.vehicle_id == "2468"
    end

    test "updates existing vehicle's assignment if it lacks a block" do
      now = BuslocTime.now()

      vehicle1 = %Vehicle{
        vehicle_id: "3579",
        block: nil,
        run: nil,
        route: "123",
        trip: "456",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        operator_id: "oper",
        operator_name: "oper name",
        timestamp: now,
        assignment_timestamp: now
      }

      assigned_logon = %AssignedLogon{
        vehicle_id: "3579",
        operator_name: "ASSIGNEDDRIVER2",
        operator_id: "51515",
        block: "S62-134",
        run: "101-2001"
      }

      update_location(:update_assigned_logon_table, vehicle1)
      update_assigned_logon(:update_assigned_logon_table, assigned_logon)
      state = get_all(:update_assigned_logon_table)

      expected_vehicle = %{
        vehicle1
        | block: "S62-134",
          route: nil,
          run: "101-2001",
          trip: nil,
          operator_id: "51515",
          operator_name: "ASSIGNEDDRIVER2"
      }

      new_vehicle = List.first(state)

      # everything except assignment_timestamp:
      assert expected_vehicle.route == new_vehicle.route
      assert expected_vehicle.run == new_vehicle.run
      assert expected_vehicle.trip == new_vehicle.trip
      assert expected_vehicle.operator_id == new_vehicle.operator_id
      assert expected_vehicle.operator_name == new_vehicle.operator_name
      assert expected_vehicle.latitude == new_vehicle.latitude
      assert expected_vehicle.longitude == new_vehicle.longitude
      assert expected_vehicle.timestamp == new_vehicle.timestamp
    end

    test "updates existing vehicle's assignment if its block is the empty string" do
      now = BuslocTime.now()

      vehicle1 = %Vehicle{
        vehicle_id: "3579",
        block: "",
        run: nil,
        route: "123",
        trip: "456",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        operator_id: "oper",
        operator_name: "oper name",
        timestamp: now,
        assignment_timestamp: now
      }

      assigned_logon = %AssignedLogon{
        vehicle_id: "3579",
        operator_name: "ASSIGNEDDRIVER2",
        operator_id: "51515",
        block: "S62-134",
        run: "101-2001"
      }

      update_location(:update_assigned_logon_table, vehicle1)
      update_assigned_logon(:update_assigned_logon_table, assigned_logon)
      state = get_all(:update_assigned_logon_table)

      expected_vehicle = %{
        vehicle1
        | block: "S62-134",
          route: nil,
          run: "101-2001",
          trip: nil,
          operator_id: "51515",
          operator_name: "ASSIGNEDDRIVER2"
      }

      new_vehicle = List.first(state)
      assert expected_vehicle.block == new_vehicle.block
    end

    test "updates with assigned logon if existing logon is stale" do
      stale_time =
        Timex.shift(BuslocTime.now(), seconds: -config(AssignedLogonFetcher, :stale_seconds) - 5)

      vehicle1 = %Vehicle{
        vehicle_id: "3579",
        block: nil,
        assignment_timestamp: stale_time,
        run: nil,
        route: "123",
        trip: "456",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        operator_id: "oper",
        operator_name: "oper name",
        timestamp: BuslocTime.now()
      }

      assigned_logon = %AssignedLogon{
        vehicle_id: "3579",
        operator_name: "ASSIGNEDDRIVER2",
        operator_id: "51515",
        block: "S62-134",
        run: "101-2001"
      }

      update_location(:update_assigned_logon_table, vehicle1)
      update_assigned_logon(:update_assigned_logon_table, assigned_logon)
      state = get_all(:update_assigned_logon_table)

      expected_vehicle = %{
        vehicle1
        | block: "S62-134",
          route: nil,
          run: "101-2001",
          trip: nil,
          operator_id: "51515",
          operator_name: "ASSIGNEDDRIVER2"
      }

      new_vehicle = List.first(state)
      assert expected_vehicle.block == new_vehicle.block
      assert expected_vehicle.route == new_vehicle.route
      assert expected_vehicle.run == new_vehicle.run
      assert expected_vehicle.operator_id == new_vehicle.operator_id
    end

    test "doesn't update with assigned logon if existing logon is not stale" do
      vehicle1 = %Vehicle{
        vehicle_id: "3579",
        block: "S76-122",
        assignment_timestamp: BuslocTime.now(),
        run: "101-2000",
        route: "123",
        trip: "456",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        operator_id: "oper",
        operator_name: "oper name",
        timestamp: BuslocTime.now()
      }

      assigned_logon = %AssignedLogon{
        vehicle_id: "3579",
        operator_name: "ASSIGNEDDRIVER2",
        operator_id: "51515",
        block: "S62-134",
        run: "101-2001"
      }

      update_location(:update_assigned_logon_table, vehicle1)
      update_assigned_logon(:update_assigned_logon_table, assigned_logon)
      state = get_all(:update_assigned_logon_table)

      expected_vehicle = vehicle1

      new_vehicle = List.first(state)
      assert expected_vehicle == new_vehicle
    end
  end

  describe "set/2" do
    setup do
      start_supervised!({Busloc.State, name: :set_table})
      :ok
    end

    test "does not delete old vehicles" do
      timestamp = DateTime.utc_now()

      vehicle1 = %Vehicle{
        vehicle_id: "1234",
        block: "A123-456",
        latitude: 42.345,
        longitude: -71.432,
        heading: 45,
        source: :transitmaster,
        timestamp: timestamp
      }

      new_vehicles = [
        %Vehicle{
          vehicle_id: "1357",
          block: "C54-321",
          latitude: 42.348,
          longitude: -70.987,
          heading: 90,
          source: :transitmaster,
          timestamp: timestamp
        },
        %Vehicle{
          vehicle_id: "2468",
          block: "B987-65",
          latitude: 42.346,
          longitude: -71.434,
          heading: 300,
          source: :transitmaster,
          timestamp: timestamp
        }
      ]

      update_location(:set_table, vehicle1)
      set(:set_table, new_vehicles)
      state = get_all(:set_table)
      assert Enum.sort(state) == Enum.sort([vehicle1 | new_vehicles])
    end

    test "an update with older TM data does not overwrite newer Samsara data" do
      vehicle_id = "1234"

      tm_vehicle = %Vehicle{
        vehicle_id: vehicle_id,
        block: "A123-45",
        latitude: 2,
        longitude: 2,
        heading: 2,
        source: :transitmaster,
        timestamp: DateTime.from_unix!(0)
      }

      samsara_vehicle = %Vehicle{
        vehicle_id: vehicle_id,
        latitude: 1,
        longitude: 1,
        heading: 1,
        source: :samsara,
        timestamp: DateTime.from_unix!(2)
      }

      tm_vehicle_update = %Vehicle{
        vehicle_id: vehicle_id,
        block: "B987-65",
        latitude: 2,
        longitude: 2,
        heading: 2,
        source: :transitmaster,
        timestamp: DateTime.from_unix!(1)
      }

      set(:set_table, [tm_vehicle])
      update_location(:set_table, samsara_vehicle)
      set(:set_table, [tm_vehicle_update])

      [merged_vehicle] = get_all(:set_table)

      assert %Vehicle{
               block: "B987-65",
               latitude: 1,
               longitude: 1,
               heading: 1
             } = merged_vehicle
    end

    test "updates assignments but not location if new lat/long are nil" do
      timestamp = DateTime.utc_now()

      vehicle1 = %Vehicle{
        vehicle_id: "1234",
        block: "A123-456",
        route: "1",
        trip: "98765432",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        timestamp: timestamp
      }

      vehicle2 = %Vehicle{
        vehicle_id: "1234",
        block: "A123-789",
        route: "10",
        trip: "87654321",
        latitude: nil,
        longitude: nil,
        heading: 90,
        source: :transitmaster,
        timestamp: Timex.shift(timestamp, minutes: 1)
      }

      expected_vehicle = %Vehicle{
        vehicle_id: "1234",
        block: "A123-789",
        route: "10",
        trip: "87654321",
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :transitmaster,
        timestamp: timestamp
      }

      set(:set_table, [vehicle1])
      set(:set_table, [vehicle2])
      state = get_all(:set_table)
      assert state == [expected_vehicle]
    end

    test "doesn't cause an empty read" do
      vehicle = %Vehicle{
        vehicle_id: "5"
      }

      set(:set_table, [vehicle])

      # spawn a task to repeatedly set the table
      loop = fn loop ->
        try do
          set(:set_table, [vehicle])
          loop.(loop)
        rescue
          ArgumentError -> :ok
        end
      end

      Task.async(fn -> loop.(loop) end)

      for _ <- 0..200 do
        refute get_all(:set_table) == []
        Process.sleep(1)
      end
    end
  end
end
