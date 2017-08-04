defmodule TripUpdates do
  @moduledoc """
  Responsible for converting lists of BoardingStatus structs into an enhanced TripUpdates JSON feed

  The basic TripUpdates feed is a Protobuf, documented here: https://developers.google.com/transit/gtfs-realtime/guides/trip-updates

  The enhanced JSON feed takes the Protobuf, expands it into JSON, and adds some additional fields.
  """

  def to_map(boarding_statuses) do
    current_time = DateTime.to_unix(DateTime.utc_now())
    %{
      header: header(current_time),
      entity: entity(current_time, boarding_statuses)
    }
  end

  def header(current_time) do
    %{
      gtfs_realtime_version: "1.0",
      timestamp: current_time
    }
  end

  def entity(current_time, boarding_statuses) do
    for {_trip_id, trip_statuses} <- Enum.group_by(
          boarding_statuses, & &1.trip_id),
      update <- trip_update(current_time, trip_statuses) do
        update
    end
  end

  def trip_update(_current_time, []) do
    []
  end
  def trip_update(current_time, [%BoardingStatus{} = status | _] = statuses) do
    [
      %{
        id: "#{current_time}_#{status.trip_id}",
        trip_update: %{
          trip: trip(status),
          stop_time_update: Enum.map(statuses, &stop_time_update/1)
        }
      }
    ]
  end

  def trip(%BoardingStatus{} = status) do
    start_date = case status.scheduled_time do
                   :unknown -> Date.utc_today()
                   dt -> DateTime.to_date(dt)
                 end
    %{
      trip_id: status.trip_id,
      route_id: status.route_id,
      direction_id: status.direction_id,
      start_date: start_date,
      schedule_relationship: "SCHEDULED"
    }
  end

  def stop_time_update(%BoardingStatus{} = status) do
    Enum.reduce([
      %{stop_id: status.stop_id},
      boarding_status_map(status.boarding_status),
      platform_id_map(status.track),
      departure_map(status.predicted_time)
    ], &Map.merge/2)
  end

  def boarding_status_map("") do
    %{}
  end
  def boarding_status_map(status) do
    %{
      boarding_status: status
    }
  end

  def platform_id_map("") do
    %{}
  end
  def platform_id_map(track) do
    %{
      platform_id: track
    }
  end

  defp departure_map(:unknown) do
    %{}
  end
  defp departure_map(%DateTime{} = dt) do
    %{
      departure: %{
        time: DateTime.to_unix(dt)
      }
    }
  end
end
