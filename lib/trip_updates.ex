defmodule TripUpdates do
  @moduledoc """
  Responsible for converting lists of BoardingStatus structs into an enhanced TripUpdates JSON feed
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
    for {trip_id, trip_statuses} <- Enum.group_by(boarding_statuses, & &1.trip_id) do
      status = List.first(trip_statuses)
      %{
        id: "#{current_time}_#{trip_id}",
        trip_update: %{
          trip: %{
            trip_id: trip_id,
            route_id: status.route_id,
            direction_id: status.direction_id,
            start_date: DateTime.to_date(status.scheduled_time),
            schedule_relationship: "SCHEDULED"
          },
          stop_time_update: Enum.map(trip_statuses, &stop_time_update/1)
        }
      }
    end
  end

  def stop_time_update(boarding_status) do
    %{
      stop_id: boarding_status.stop_id,
      departure: %{
        time: boarding_status.predicted_time,
      },
      schedule_relationship: "SCHEDULED",
      boarding_status: boarding_status.boarding_status,
      platform_id: boarding_status.track
    }
  end
end
