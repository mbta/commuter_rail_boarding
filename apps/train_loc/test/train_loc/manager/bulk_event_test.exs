defmodule TrainLoc.Manager.BulkEventTest do
  use ExUnit.Case, async: true
  import Jason.Sigil
  alias TrainLoc.Manager.BulkEvent
  alias TrainLoc.Vehicles.Vehicle

  @old_bulk_event File.read!("test/data/old_bulk_event.json")
  @new_bulk_event File.read!("test/data/new_bulk_event.json")
  @new_bulk_event_small File.read!("test/data/new_bulk_event_small.json")

  describe "valid_bulk_event?/1" do
    test "rejects an old-style bulk event" do
      assert {:error, :invalid_event, _} = BulkEvent.parse(@old_bulk_event)
    end

    test "rejects a single vehicle event" do
      single_event = ~J({"path":"/results/1634","data":{
          "Heading":172,
          "Latitude":42.77496,
          "Longitude":-71.08655,
          "PatID":211,
          "Speed":0,
          "TripID":211,
          "Update Time":"2022-01-18T15:53:05.000Z",
          "VehicleID":1634,
          "WorkID":211}})

      assert {:error, :invalid_event, _} = BulkEvent.parse(single_event)
    end

    test "rejects a processResults event" do
      process_results_event =
        ~J({"path":"/processResults","data":{"date":"January 18, 2022 3:53:15 PM","results":49}})

      assert {:error, :invalid_event, _} = BulkEvent.parse(process_results_event)
    end

    test "rejects a null event" do
      null_event = ~J({"path":"/","data":null})

      assert {:error, :invalid_event, _} = BulkEvent.parse(null_event)
    end

    test "accepts a real bulk event" do
      assert {:ok, [_event | _rest]} = BulkEvent.parse(@new_bulk_event)
    end
  end

  describe "parse/1" do
    test "parses a valid event into a list of vehicles" do
      assert {:ok,
              [
                %Vehicle{
                  heading: 0.0,
                  latitude: 42.240323,
                  longitude: -71.128225,
                  speed: 0,
                  trip: :unassigned,
                  timestamp:
                    DateTime.new!(~D[2020-02-25], ~T[12:47:58.490000], "America/New_York"),
                  vehicle_id: 1506,
                  block: nil
                },
                %Vehicle{
                  heading: 0.0,
                  latitude: 42.240323,
                  longitude: -71.127625,
                  speed: 0,
                  trip: :unassigned,
                  timestamp:
                    DateTime.new!(~D[2020-12-14], ~T[10:19:54.883000], "America/New_York"),
                  vehicle_id: 1507,
                  block: nil
                },
                %Vehicle{
                  heading: 199.0,
                  latitude: 42.23879,
                  longitude: -71.13356,
                  speed: 1,
                  timestamp: DateTime.new!(~D[2022-01-18], ~T[16:29:00], "America/New_York"),
                  trip: "745",
                  vehicle_id: 1823,
                  block: nil
                }
              ]} == BulkEvent.parse(@new_bulk_event_small)
    end
  end
end
