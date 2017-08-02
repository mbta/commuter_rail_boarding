defmodule BoardingStatus do
  @moduledoc """
  Structure to represent the status of a single train
  """
  require Logger

  defstruct [
    scheduled_time: :unknown,
    predicted_time: :unknown,
    route_id: :unknown,
    trip_id: :unknown,
    direction_id: :unknown,
    stop_id: :unknown,
    boarding_status: "",
    track: ""
  ]

  @type route_id :: binary
  @type trip_id :: binary
  @type stop_id :: binary
  @type direction_id :: 0 | 1
  @type t :: %__MODULE__{
    scheduled_time: :unknown | DateTime.t,
    predicted_time: :unknown | DateTime.t,
    route_id: :unknown | route_id,
    trip_id: :unknown | trip_id,
    direction_id: :unknown | direction_id,
    stop_id: :unknown | stop_id,
    boarding_status: String.t,
    track: String.t
  }

  @doc "Builds a BoardingStatus from the data we get out of Firebase"
  @spec from_firebase(map) :: {:ok, t} | :error
  def from_firebase(map) do
    with {:ok, scheduled_time, _} <- DateTime.from_iso8601(map["gtfs_departure_time"]),
         trip_id = map["gtfs_trip_id"],
         {:ok, route_id, direction_id} <- TripCache.route_direction_id(trip_id),
         {:ok, stop_id} <- stop_id(map["gtfs_stop_name"]) do
      {:ok, %__MODULE__{
          scheduled_time: scheduled_time,
          predicted_time: predicted_time(map["gtfsrt_departure"], scheduled_time),
          route_id: route_id,
          trip_id: trip_id,
          stop_id: stop_id,
          direction_id: direction_id,
          boarding_status: map["current_display_status"],
          track: map["track"]
       }
      }
    else
      _ ->
        _ = Logger.error(fn -> "unable to parse firebase map: #{inspect map}" end)
        :error
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
      Application.get_env(:commuter_rail_boarding, :stop_ids),
      stop_name)
  end
end
