defmodule TrainLoc.ManagerTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureLog
  import TrainLoc.Utilities.ConfigHelpers
  alias ServerSentEventStage.Event, as: ServerSentEvent
  alias TrainLoc.Manager
  alias TrainLoc.Utilities.Time, as: TrainLocTime
  alias TrainLoc.Vehicles.PreviousBatch
  alias TrainLoc.Vehicles.Vehicle

  setup do
    Application.ensure_all_started(:train_loc)

    on_exit(fn ->
      Manager.reset()
      TrainLoc.Conflicts.State.reset()
      TrainLoc.Vehicles.State.reset()
    end)
  end

  describe "handle_info/2" do
    test "logs a warning with invalid messages" do
      message = {:unknown, System.unique_integer()}

      log =
        capture_log(fn ->
          send(Manager, message)
          Manager.await()
        end)

      assert log =~ inspect(message)
    end
  end

  describe "`:events` callback logs 'only old locations in batch' warning" do
    test "logs warning if batch has same data as previous batch" do
      vehicle_1_data = %{
        "Heading" => 0,
        "Latitude" => 42.24005,
        "Longitude" => -71.12007,
        "TripID" => 123,
        "Speed" => 7,
        "Update Time" => generate_invalid_timestamp(),
        "VehicleID" => 1712,
        "WorkID" => 0
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
        # flips `first_message?` flag to false
        send(Manager, {:events, []})
        send(Manager, {:events, events})
        Manager.await()
      end

      assert capture_log(fun) =~ PreviousBatch.only_old_locations_warning()
    end

    test "doesn't log warning if batch has different data than previous batch" do
      timestamp = generate_invalid_timestamp()
      datetime_timestamp = TrainLocTime.parse_improper_iso(timestamp)

      previous_batch = [
        %Vehicle{
          heading: 0,
          latitude: 42.24,
          longitude: -71.12,
          trip: 123,
          speed: 7,
          timestamp: datetime_timestamp,
          vehicle_id: 1712,
          block: 234
        }
      ]

      PreviousBatch.put(previous_batch)

      vehicle_1_data = %{
        data: %{
          heading: 0,
          # <- different latitude than in 'previous batch'
          latitude: 92.24,
          # <- different longitude than in 'previous batch'
          longitude: -21.12,
          routename: 123,
          speed: 7,
          updatetime: timestamp,
          vehicleid: 1712,
          workid: 234
        }
      }

      end_of_batch_event_data = %{data: %{date: "some date"}}

      events =
        for data <- [vehicle_1_data, end_of_batch_event_data] do
          %ServerSentEvent{event: "put", data: Poison.encode!(data)}
        end

      fun = fn ->
        # flips `first_message?` flag to false
        send(Manager, {:events, []})
        send(Manager, {:events, events})
        Manager.await()
      end

      refute capture_log(fun) =~ PreviousBatch.only_old_locations_warning()
    end
  end

  describe "vehicles_from_data/1" do
    @invalid_json %{
      "Latitude" => 42.37405,
      "Longitude" => -71.07496,
      "TripID" => 0,
      "Speed" => 0,
      "Update Time" => "2018-01-16T15:03:27Z",
      "VehicleID" => 1633,
      "WorkID" => 0
    }
    test "logs message if vehicle validation fails" do
      fun = fn ->
        Manager.vehicles_from_data(@invalid_json)
      end

      assert capture_log(fun) =~ "Manager Vehicle Validation"
    end
  end

  defp generate_invalid_timestamp do
    local_offset =
      :time_zone
      |> config()
      |> Timex.Timezone.get()
      |> Timex.Timezone.total_offset()

    DateTime.utc_now()
    |> Timex.shift(seconds: local_offset)
    |> Timex.format!("{ISO:Extended:Z}")
  end
end
