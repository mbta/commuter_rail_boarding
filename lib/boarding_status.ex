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
    boarding_status: "",
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
  * boarding_status: what appears on the big board in the station
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
    boarding_status: String.t,
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
  * `current_display_status`: maps to `boarding_status`
  * `track`: maps to `track

  There are examples of this data in test/fixtures/firebase.json
  """
  @spec from_firebase(map) :: {:ok, t} | :error
  def from_firebase(map) do
    with {:ok, scheduled_time, _} <- DateTime.from_iso8601(map["gtfs_departure_time"]),
         {:ok, stop_id} <- stop_id(map["gtfs_stop_name"]),
         {:ok, trip_id, route_id, direction_id, added?} <-
           trip_route_direction_id(map) do
      {:ok, %__MODULE__{
          scheduled_time: scheduled_time,
          predicted_time: predicted_time(map["gtfsrt_departure"], scheduled_time),
          route_id: route_id,
          trip_id: trip_id,
          stop_id: stop_id,
          direction_id: direction_id,
          boarding_status: map["current_display_status"],
          track: map["track"],
          added?: added?
       }
      }
    else
      _ ->
        _ = Logger.warn(fn -> "unable to parse firebase map: #{inspect map}" end)
        :error
    end
  end

  defp trip_route_direction_id(%{"gtfs_trip_id" => ""} = map) do
    long_name = map["gtfs_route_long_name"]
    with {:ok, route_id} <- RouteCache.id_from_long_name(long_name) do
      case map["gtfs_trip_short_name"] do
        "" -> :ok
        short_name ->
          Logger.warn(fn ->
            trip_id = map["trip_id"]
            "unexpected missing GTFS trip ID: \
route #{route_id}, short name #{short_name}, trip ID #{trip_id}"
          end)
      end
      trip_id = "CRB_#{map["trip_id"]}"
      direction_id = :unknown
      {:ok, trip_id, route_id, direction_id, true}
    end
  end
  defp trip_route_direction_id(%{"gtfs_trip_id" => trip_id}) do
    with {:ok, route_id, direction_id} <- TripCache.route_direction_id(
           trip_id) do
      {:ok, trip_id, route_id, direction_id, false}
    end
  end

  defp predicted_time("", scheduled_time) do
    scheduled_time
  end
  defp predicted_time(iso_dt, scheduled_time) do
    with {:ok, predicted_time, _} <- DateTime.from_iso8601(iso_dt) do
      predicted_time
    else
      _ -> scheduled_time
    end
  end

  def stop_id(stop_name) do
    Map.fetch(
      config(:stop_ids),
      stop_name)
  end
end
