defmodule BoardingStatus do
  @moduledoc """
  Structure to represent the status of a single train
  """
  defstruct [
    scheduled_time: :unknown,
    predicted_time: :unknown,
    route_id: :unknown,
    trip_id: :unknown,
    stop_id: :unknown,
    boarding_status: "",
    track: ""
  ]

  @doc "Builds a BoardingStatus from the data we get out of Firebase"
  def from_firebase(map) do
    {:ok, scheduled_time, _} = DateTime.from_iso8601(map["gtfs_departure_time"])
    %__MODULE__{
      scheduled_time: scheduled_time,
      predicted_time: scheduled_time,
      trip_id: map["gtfs_trip_id"],
      stop_id: stop_id(map["gtfs_stop_name"]),
      boarding_status: map["current_display_status"],
      track: map["track"]
    }
  end

  def stop_id(stop_name) do
    Map.get(
      Application.get_env(:commuter_rail_boarding, :stop_ids),
      stop_name, :unknown)
  end
end
