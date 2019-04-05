defmodule Busloc.StateTest do
  use ExUnit.Case, async: true
  alias Busloc.Vehicle
  import Busloc.State

  describe "update/2" do
    setup do
      start_supervised!({Busloc.State, name: :update_table})
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

      update(:update_table, vehicle)
      from_state = get_all(:update_table)
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

      update(:update_table, vehicle1)
      update(:update_table, vehicle2)
      state = get_all(:update_table)

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

      update(:update_table, vehicle1)
      update(:update_table, vehicle2)
      state = get_all(:update_table)
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

      update(:update_table, vehicle1)
      update(:update_table, vehicle2)
      state = get_all(:update_table)
      assert state == [vehicle1]
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

      update(:set_table, vehicle1)
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
      update(:set_table, samsara_vehicle)
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
