defmodule TrainLoc.ManagerTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureLog
  import TrainLoc.Utilities.ConfigHelpers
  alias ServerSentEventStage.Event, as: ServerSentEvent
  alias TrainLoc.Manager
  alias TrainLoc.S3
  alias TrainLoc.Utilities.Time, as: TrainLocTime
  alias TrainLoc.Vehicles.PreviousBatch
  alias TrainLoc.Vehicles.Vehicle

  setup do
    Application.ensure_all_started(:train_loc)
    S3.InMemory.start()

    on_exit(fn ->
      Manager.reset()
      S3.InMemory.stop()
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

    test ":timeout reschedules the timer" do
      state = %Manager{producers: []}

      assert {:noreply, [], state2} = Manager.handle_info(:timeout, state)
      assert state2.timeout_ref != state.timeout_ref
    end

    test ":timeout refreshes the connection" do
      state = %Manager{producers: [:x], refresh_fn: &__MODULE__.send_self/1}

      log =
        capture_log([level: :warn], fn ->
          Manager.handle_info(:timeout, state)

          assert_received :x
        end)

      assert log =~ "Connection timed out, refreshing..."
    end
  end

  describe "handle_events/3" do
    @state %Manager{
      producers: [:one, :two],
      refresh_fn: &__MODULE__.send_self/1
    }

    test "refreshes when any of the events were `auth_revoked`" do
      events =
        for event <- ~w(put keep-alive auth_revoked) do
          %ServerSentEventStage.Event{event: event}
        end

      Manager.handle_events(events, self(), @state)
      assert_received :one
      assert_received :two
    end

    test "does not refresh when none of the events were `auth_revoked`" do
      events =
        for event <- ~w(put keep-alive) do
          %ServerSentEventStage.Event{event: event}
        end

      Manager.handle_events(events, self(), @state)
      refute_received :one
      refute_received :two
    end
  end

  describe "upload_feed/2" do
    test "uploads to new bucket root" do
      Manager.upload_feed("gtfs", %{new_bucket: :new_bucket})
      objects = S3.InMemory.list_objects()

      assert Map.has_key?(objects, :new_bucket)
      assert Map.has_key?(objects.new_bucket, "VehiclePositions_enhanced.json")
    end

    test "doesn't apply public_read ACL in new bucket" do
      Manager.upload_feed("gtfs", %{new_bucket: :new_bucket})
      objects = S3.InMemory.list_objects()

      assert Map.has_key?(objects, :new_bucket)
      refute objects.new_bucket["opts"] == [acl: :public_read]
    end

    test "uploads to correct path in current bucket" do
      Manager.upload_feed("gtfs", %{new_bucket: :new_bucket})
      objects = S3.InMemory.list_objects()

      assert Map.has_key?(objects, :default)

      assert Map.has_key?(
               objects.default,
               "train_loc/VehiclePositions_enhanced.json"
             )
    end

    test "applys public_read ACL in current bucket" do
      Manager.upload_feed("gtfs", %{new_bucket: :new_bucket})
      objects = S3.InMemory.list_objects()

      assert Map.has_key?(objects, :default)
      assert objects.default["opts"] == [acl: :public_read]
    end
  end

  describe "`:events` callback logs 'only old locations in batch' warning" do
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
          %ServerSentEvent{event: "put", data: Jason.encode!(data)}
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

  describe "timeouts" do
    test "receives a timeout message if we haven't gotten an event" do
      Manager.init(subscribe_to: [], timeout_after: 50)
      assert_receive :timeout
    end

    test "does not receive a timeout after a message" do
      {_, state, _} = Manager.init(subscribe_to: [], timeout_after: 50)
      {_, [], state2} = Manager.handle_events([], :from, state)
      refute_received :timeout
      assert state2.timeout_ref != state.timeout_ref
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

  def send_self(message) do
    send(self(), message)
  end

  describe "generate_feed/2" do
    test "generates a feed from new vehicles" do
      vehicles = [
        %Vehicle{
          heading: 0.0,
          latitude: 42.240323,
          longitude: -71.128225,
          speed: 0,
          trip: :unassigned,
          timestamp: ~U[2022-01-20 23:43:42Z],
          vehicle_id: 1506
        },
        %Vehicle{
          heading: 0.0,
          latitude: 42.240323,
          longitude: -71.127625,
          speed: 0,
          trip: :unassigned,
          timestamp: ~U[2022-01-20 23:43:42Z],
          vehicle_id: 1507
        },
        %Vehicle{
          heading: 199.0,
          latitude: 42.23879,
          longitude: -71.13356,
          speed: 1,
          timestamp: ~U[2022-01-20 23:43:42Z],
          trip: "745",
          vehicle_id: 1823
        },
        %Vehicle{
          heading: 123.4,
          latitude: 56.78901,
          longitude: -23.45678,
          speed: 1,
          timestamp: ~U[2022-01-20 23:43:42Z],
          trip: "123",
          vehicle_id: 1234
        },
        %Vehicle{
          heading: 120.4,
          latitude: 52.78901,
          longitude: -24.45678,
          speed: 1,
          timestamp: ~U[2022-01-20 23:11:42Z],
          trip: "129",
          vehicle_id: 56_789
        }
      ]

      assert [
               %{
                 "id" => "54134678",
                 "vehicle" => %{
                   "position" => %{
                     "bearing" => 0.0,
                     "latitude" => 42.240323,
                     "longitude" => -71.128225,
                     "speed" => 0.0
                   },
                   "timestamp" => 1_642_722_222,
                   "trip" => %{"start_date" => "20220120"},
                   "vehicle" => %{"id" => "1506"}
                 }
               },
               %{
                 "id" => "83231832",
                 "vehicle" => %{
                   "position" => %{
                     "bearing" => 0.0,
                     "latitude" => 42.240323,
                     "longitude" => -71.127625,
                     "speed" => 0.0
                   },
                   "timestamp" => 1_642_722_222,
                   "trip" => %{"start_date" => "20220120"},
                   "vehicle" => %{"id" => "1507"}
                 }
               },
               %{
                 "id" => "59176583",
                 "vehicle" => %{
                   "position" => %{
                     "bearing" => 199.0,
                     "latitude" => 42.23879,
                     "longitude" => -71.13356,
                     "speed" => 0.447
                   },
                   "timestamp" => 1_642_722_222,
                   "trip" => %{"start_date" => "20220120", "trip_short_name" => "745"},
                   "vehicle" => %{"id" => "1823"}
                 }
               }
             ] ==
               Manager.generate_feed(vehicles, %{
                 excluded_vehicles: [1234],
                 time_baseline: fn -> 1_642_722_222 end
               })
               |> Jason.decode!()
               |> Map.get("entity")
    end
  end
end
