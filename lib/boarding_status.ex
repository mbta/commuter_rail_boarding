defmodule BoardingStatus do
  @moduledoc """
  Structure to represent the status of a single train
  """
  require Logger
  import ConfigHelpers

  defstruct [
    scheduled_time: :unknown,
    predicted_time: :unknown,
    route_id: :unknown,
    trip_id: :unknown,
    direction_id: :unknown,
    stop_id: :unknown,
    stop_sequence: :unknown,
    status: :unknown,
    track: "",
    added?: false
  ]

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
    scheduled_time: :unknown | DateTime.t,
    predicted_time: :unknown | DateTime.t,
    route_id: :unknown | route_id,
    trip_id: :unknown | trip_id,
    direction_id: :unknown | direction_id,
    stop_id: :unknown | stop_id,
    stop_sequence: :unknown | non_neg_integer,
    status: atom,
    track: String.t,
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
  @spec from_firebase(map) :: {:ok, t} | :error
  def from_firebase(%{
        "gtfs_departure_time" => schedule_time_iso,
        "gtfs_stop_name" => stop_name,
        "gtfsrt_departure" => predicted_time_iso,
        "status" => status,
        "track" => track} = map) do
    with {:ok, scheduled_time, _} <- DateTime.from_iso8601(schedule_time_iso),
         {:ok, trip_id, route_id, direction_id, added?} <-
           trip_route_direction_id(map) do
      stop_id = stop_id(stop_name)
      {:ok, %__MODULE__{
          scheduled_time: scheduled_time,
          predicted_time: predicted_time(
            predicted_time_iso, scheduled_time, status),
          route_id: route_id,
          trip_id: trip_id,
          stop_id: stop_id,
          stop_sequence: stop_sequence(trip_id, stop_id, added?),
          direction_id: direction_id,
          status: status_atom(status),
          track: track,
          added?: added?
       }
      }
    else
      error ->
        _ = Logger.warn(fn -> "unable to parse firebase map: #{inspect map}: #{inspect error}" end)
        :error
    end
  end

  defp trip_route_direction_id(%{
        "gtfs_trip_id" => "",
        "gtfs_route_long_name" => long_name,
        "gtfs_trip_short_name" => trip_name,
        "trip_id" => keolis_trip_id}) do
    # no ID, but maybe we can look it up with the trip name
    with {:ok, route_id} <- RouteCache.id_from_long_name(long_name),
         {:ok, trip_id, direction_id, added?} <- create_trip_id(
           route_id, trip_name, keolis_trip_id) do
      {:ok, trip_id, route_id, direction_id, added?}
    end
  end
  defp trip_route_direction_id(%{"gtfs_trip_id" => trip_id}) do
    # easy case: we have a trip ID, so we look up the route/direction
    with {:ok, route_id, direction_id} <- TripCache.route_direction_id(
           trip_id) do
      {:ok, trip_id, route_id, direction_id, false}
    end
  end

  defp create_trip_id(route_id, "", keolis_trip_id) do
    # no trip name, build a new trip_id
    _ = Logger.warn(fn ->
      "creating trip for Keolis trip #{route_id} (#{keolis_trip_id})"
    end)
    {:ok, "CRB_" <> keolis_trip_id, :unknown, true}
  end
  defp create_trip_id(route_id, trip_name, keolis_trip_id) do
    case TripCache.route_trip_name_to_id(route_id, trip_name) do
      {:ok, trip_id, direction_id} ->
        _ = Logger.warn(fn ->
          "matched trip #{trip_id} based on #{route_id} #{trip_name}"
        end)
        {:ok, trip_id, direction_id, false}
      :error ->
        # couldn't match the trip name: log a warning but build a trip ID
        # anyways.
        _ = Logger.warn(fn ->
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
    with {:ok, predicted_time, _} <- DateTime.from_iso8601(iso_dt) do
      predicted_time
    else
      _ -> scheduled_time
    end
  end

  def stop_id(stop_name) do
    Map.get(
      config(:stop_ids),
      stop_name,
      stop_name)
  end

  def status_atom("") do
    :unknown
  end
  for {status, atom} <- Application.get_env(
        :commuter_rail_boarding, :statuses) do
      # build a function for each status in the map
    def status_atom(unquote(status)) do
      unquote(atom)
    end
  end
  def status_atom(status) do
    _ = Logger.warn(fn -> "unknown status: #{inspect status}" end)
    :unknown
  end
end
