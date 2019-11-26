defmodule BoardingStatus do
  @moduledoc """
  Structure to represent the status of a single train
  """
  require Logger
  import ConfigHelpers

  defstruct scheduled_time: :unknown,
            predicted_time: :unknown,
            route_id: :unknown,
            trip_id: :unknown,
            direction_id: :unknown,
            stop_id: :unknown,
            stop_sequence: :unknown,
            status: :unknown,
            track: "",
            added?: false

  @type route_id :: binary
  @type trip_id :: binary
  @type stop_id :: binary
  @type direction_id :: 0 | 1
  @typedoc """
  * scheduled_time: When the train is supposed to leave the station
  * predicted_time: When we expect the train to leave the station
  * route_id: GTFS route ID
  * trip_id: GTFS trip ID, or some other value for added trips
  * direction_id: GTFS direction ID
  * stop_id: GTFS stop ID
  * status: atom representing what appears on the big board in the station
  * track: the track the train will be on, or empty if not provided
  * added?: true if the trip isn't included in the GTFS schedule
  """
  @type t :: %__MODULE__{
          scheduled_time: :unknown | DateTime.t(),
          predicted_time: :unknown | DateTime.t(),
          route_id: :unknown | route_id,
          trip_id: :unknown | trip_id,
          direction_id: :unknown | direction_id,
          stop_id: :unknown | stop_id,
          stop_sequence: :unknown | non_neg_integer,
          status: String.t() | :unknown,
          track: String.t(),
          added?: boolean
        }

  @doc """
  Builds a BoardingStatus from the data we get out of Firebase.

  Firebase keys, and their mappings to BoardingStatus fields:
  * `gtfs_departure_time`: an ISO DateTime, maps to `scheduled_time`
  * `gtfs_trip_id`: maps to `trip_id` (and `route_id`/`direction_id`)
  * `gtfsrt_departure`: an ISO DateTime, maps to `predicted_time`
     (will use the scheduled_time if empty)
  * `status`: maps to `status`
  * `track`: maps to `track

  There are examples of this data in test/fixtures/firebase.json
  """
  @spec from_firebase(map) :: {:ok, t} | :ignore | :error
  def from_firebase(
        %{
          "gtfs_departure_time" => schedule_time_iso,
          "gtfs_stop_name" => stop_name,
          "gtfsrt_departure" => predicted_time_iso,
          "status" => status,
          "track" => track
        } = map
      ) do
    with :ok <- validate_movement_type(map),
         :ok <- validate_is_stopping(map),
         {:ok, scheduled_time, _} <- DateTime.from_iso8601(schedule_time_iso),
         {:ok, trip_id, route_id, direction_id, added?} <-
           trip_route_direction_id(map, scheduled_time) do
      stop_id = stop_id(stop_name)

      {:ok,
       %__MODULE__{
         scheduled_time: scheduled_time,
         predicted_time:
           predicted_time(predicted_time_iso, scheduled_time, status),
         route_id: route_id,
         trip_id: trip_id,
         stop_id: stop_id,
         stop_sequence: stop_sequence(trip_id, stop_id, added?),
         direction_id: direction_id,
         status: status_string(status),
         track: track,
         added?: added?
       }}
    else
      :ignore ->
        :ignore

      error ->
        _ =
          Logger.warn(fn ->
            "unable to parse firebase map: #{inspect(map)}: #{inspect(error)}"
          end)

        :error
    end
  end

  def from_firebase(%{} = map) do
    _ =
      Logger.warn(fn ->
        "unable to match firebase map: #{inspect(map)}"
      end)

    :error
  end

  def validate_movement_type(%{"movement_type" => type})
      when type in ~w(O B E) do
    # O - Originating
    # B - Both End Train and Detrain
    # E - End Train only
    :ok
  end

  def validate_movement_type(%{"movement_type" => _}) do
    # other movement types shouldn't get boarding statuses
    :ignore
  end

  def validate_movement_type(%{}) do
    # without a movement type, treat it as okay
    :ok
  end

  # We can ignore any object with is_Stopping False
  def validate_is_stopping(%{"is_Stopping" => "False"}), do: :ignore
  def validate_is_stopping(_), do: :ok

  defp trip_route_direction_id(
         %{
           "gtfs_route_long_name" => long_name,
           "gtfs_trip_short_name" => trip_name,
           "trip_id" => keolis_trip_id
         },
         dt
       ) do
    # we can look the trip ID up with the trip name
    with {:ok, route_id} <- RouteCache.id_from_long_name(long_name),
         {:ok, trip_id, direction_id, added?} <-
           create_trip_id(route_id, trip_name, keolis_trip_id, dt) do
      {:ok, trip_id, route_id, direction_id, added?}
    end
  end

  defp create_trip_id(route_id, "", keolis_trip_id, _dt) do
    # no trip name, build a new trip_id
    _ =
      Logger.warn(fn ->
        "creating trip for Keolis trip #{route_id} (#{keolis_trip_id})"
      end)

    {:ok, "CRB_" <> keolis_trip_id, :unknown, true}
  end

  defp create_trip_id(route_id, trip_name, keolis_trip_id, dt) do
    case TripCache.route_trip_name_to_id(route_id, trip_name, dt) do
      {:ok, trip_id, direction_id} ->
        {:ok, trip_id, direction_id, false}

      :error ->
        # couldn't match the trip name: log a warning but build a trip ID
        # anyways.
        _ =
          Logger.warn(fn ->
            "unexpected missing GTFS trip ID: \
route #{route_id}, name #{trip_name}, trip ID #{keolis_trip_id}"
          end)

        {:ok, "CRB_#{keolis_trip_id}_#{trip_name}", :unknown, true}
    end
  end

  defp stop_sequence(trip_id, stop_id, added?)

  defp stop_sequence(_, _, true) do
    # added trips don't have a stop sequence ID
    :unknown
  end

  defp stop_sequence(trip_id, stop_id, _) do
    case ScheduleCache.stop_sequence(trip_id, stop_id) do
      {:ok, sequence} -> sequence
      :error -> :unknown
    end
  end

  defp predicted_time(iso_dt, scheduled_time, status)

  defp predicted_time(_, _, "CX") do
    # cancelled trips don't have a predictions
    :unknown
  end

  defp predicted_time("", scheduled_time, _) do
    scheduled_time
  end

  defp predicted_time(iso_dt, scheduled_time, _) do
    case DateTime.from_iso8601(iso_dt) do
      {:ok, predicted_time, _} ->
        predicted_time

      _ ->
        scheduled_time
    end
  end

  def stop_id(stop_name) do
    Map.get(config(:stop_ids), stop_name, stop_name)
  end

  statuses = Application.get_env(:commuter_rail_boarding, :statuses)

  for {status, string} <- statuses do
    # build a function for each status in the map
    def status_string(unquote(status)) do
      unquote(string)
    end
  end

  def status_string(status) do
    _ = Logger.warn(fn -> "unknown status: #{inspect(status)}" end)
    :unknown
  end
end
