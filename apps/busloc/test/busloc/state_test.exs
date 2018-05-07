defmodule Busloc.StateTest do
  use ExUnit.Case, async: true
  alias Busloc.Vehicle
  import Busloc.State

  describe "update/2" do
    setup do
      {:ok, pid} = start_link()
      {:ok, %{pid: pid}}
    end

    test "Stores and retrieves single vehicle", %{pid: pid} do
      vehicle = %Vehicle{
        vehicle_id: "1234",
        block: nil,
        latitude: 42.345,
        longitude: -71.43,
        heading: 45,
        source: :samsara,
        timestamp: DateTime.utc_now()
      }

      update(pid, vehicle)
      from_state = get_all(pid)
      assert from_state == [vehicle]
    end

    test "updates existing vehicle if timestamp is newer", %{pid: pid} do
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

      update(pid, vehicle1)
      update(pid, vehicle2)
      state = get_all(pid)
      assert state == [%{vehicle2 | block: "A123-456"}]
    end

    test "doesn't update if the timestamp is older", %{pid: pid} do
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

      update(pid, vehicle1)
      update(pid, vehicle2)
      state = get_all(pid)
      assert state == [vehicle1]
    end
  end

  describe "set/2" do
    setup do
      {:ok, pid} = start_link()
      {:ok, %{pid: pid}}
    end

    test "overwrites previous state", %{pid: pid} do
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

      update(pid, vehicle1)
      set(pid, new_vehicles)
      state = get_all(pid)
      assert state == new_vehicles
    end
  end
end
