defmodule TrainLoc.ManagerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias TrainLoc.Manager
  alias TrainLoc.Input.ServerSentEvent
  alias TrainLoc.Vehicles.PreviousBatch
  alias TrainLoc.Vehicles.Vehicle
  alias TrainLoc.Utilities.Time

  setup do
    Application.ensure_all_started(:trainloc)

    on_exit fn ->
      Manager.reset()
      TrainLoc.Conflicts.State.reset()
      TrainLoc.Vehicles.State.reset()
    end
  end

  describe "`:events` callback logs 'only old locations in batch' warning" do
    test "logs warning if batch has same data as previous batch" do
      unix_timestamp = DateTime.to_unix(DateTime.utc_now())
      vehicle_1_data = %{
        "fix" => 3,
        "heading" => 0,
        "latitude" => 4224005,
        "longitude" => -7112007,
        "routename" => "some trip",
        "speed" => 7,
        "updatetime" => unix_timestamp,
        "vehicleid" => 1712,
        "workid" => 0
      }
      vehicle_1 = Vehicle.from_json(vehicle_1_data)
      previous_batch = [vehicle_1]
      PreviousBatch.put(previous_batch)

      end_of_batch_event_data = %{data: %{date: "some date"}}
      events =
        for data <- [vehicle_1_data, end_of_batch_event_data] do
          %ServerSentEvent{event: "put", data: Poison.encode!(data)}
        end

      fun = fn ->
        send(Manager, {:events, []}) # flips `first_message?` flag to false
        send(Manager, {:events, events})
        Manager.await()
      end

      assert capture_log(fun) =~ PreviousBatch.only_old_locations_warning()
    end

    test "doesn't log warning if batch has different data than previous batch" do
      unix_timestamp = DateTime.to_unix(DateTime.utc_now())
      datetime_timestamp = Time.parse_improper_unix(unix_timestamp)
      previous_batch = [
        %Vehicle{
          fix: 3,
          heading: 0,
          latitude: 42.24 / 100000,
          longitude: -71.12 / 100000,
          trip: "some trip",
          speed: 7,
          timestamp: datetime_timestamp,
          vehicle_id: 1712,
          block: "some block",
        }
      ]
      PreviousBatch.put(previous_batch)
      vehicle_1_data = %{
        data: %{
          fix: 3,
          heading: 0,
          latitude: 92.24, # <- different latitude than in 'previous batch'
          longitude: -21.12, # <- different longitude than in 'previous batch'
          routename: "some trip",
          speed: 7,
          updatetime: unix_timestamp,
          vehicleid: 1712,
          workid: "some block"
        }
      }
      end_of_batch_event_data = %{data: %{date: "some date"}}
      events =
        for data <- [vehicle_1_data, end_of_batch_event_data] do
          %ServerSentEvent{event: "put", data: Poison.encode!(data)}
        end

      fun = fn ->
        send(Manager, {:events, []}) # flips `first_message?` flag to false
        send(Manager, {:events, events})
        Manager.await()
      end

      refute capture_log(fun) =~ PreviousBatch.only_old_locations_warning()
    end
  end
end
