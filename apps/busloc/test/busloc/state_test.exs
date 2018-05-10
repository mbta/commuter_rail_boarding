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
        timestamp: Timex.shift(timestamp, minutes: 1)
      }

      update(:update_table, vehicle1)
      update(:update_table, vehicle2)
      state = get_all(:update_table)
      assert state == [%{vehicle2 | block: "A123-456"}]
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
  end

  describe "set/2" do
    setup do
      start_supervised!({Busloc.State, name: :set_table})
      :ok
    end

    test "overwrites previous state" do
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
      assert Enum.sort(state) == Enum.sort(new_vehicles)
    end
  end
end
