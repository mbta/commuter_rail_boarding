defmodule Busloc.Encoder.VehiclePositionsEnhancedTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Encoder.VehiclePositionsEnhanced
  alias Busloc.Vehicle

  describe "encode/1" do
    test "returns JSON" do
      assert {:ok, _} = Poison.decode(encode([]))
    end
  end

  describe "header/0" do
    test "includes basic fields" do
      assert %{
               gtfs_realtime_version: _,
               incrementality: 0
             } = header()
    end

    test "changes the timestamp every second" do
      first = header()
      Process.sleep(1_001)
      second = header()

      refute first.timestamp == second.timestamp
    end
  end

  describe "entity/1" do
    test "renders an entity for a vehicle" do
      v = %Vehicle{
        vehicle_id: "vehicle_id",
        block: "block",
        route: "route",
        trip: "trip",
        latitude: 1.234,
        longitude: -56.789,
        heading: 90,
        source: :transitmaster,
        timestamp: DateTime.utc_now(),
        start_date: ~D[2018-04-30]
      }

      actual_entity = entity(v)

      assert %{
               id: <<_::binary>>,
               is_deleted: false,
               vehicle: %{
                 trip: %{},
                 vehicle: %{},
                 position: %{},
                 block_id: _,
                 location_source: _,
                 timestamp: _
               }
             } = actual_entity

      assert actual_entity.vehicle.trip == %{
               trip_id: v.trip,
               route_id: v.route,
               schedule_relationship: :SCHEDULED,
               start_date: "20180430"
             }

      assert actual_entity.vehicle.vehicle == %{
               id: v.vehicle_id
             }

      assert actual_entity.vehicle.position == %{
               latitude: v.latitude,
               longitude: v.longitude,
               bearing: v.heading
             }

      assert actual_entity.vehicle.block_id == v.block
      assert actual_entity.vehicle.timestamp == DateTime.to_unix(v.timestamp)
    end

    test "without a trip ID, we generate a trip ID" do
      v = %Vehicle{vehicle_id: "veh", timestamp: DateTime.utc_now()}
      actual_entity = entity(v)

      assert %{trip_id: <<_::binary>>, schedule_relationship: :UNSCHEDULED} =
               actual_entity.vehicle.trip
    end
  end
end
