defmodule Busloc.Tsp do
  defstruct [
    :guid,
    :traffic_signal_event_id,
    :event_type,
    :event_time,
    :event_geo_node,
    :vehicle_id,
    :route_id,
    :approach_direction,
    :latitude,
    :longitude,
    :deviation_from_schedule,
    :bus_load,
    :distance
  ]

  @type t :: %__MODULE__{
          guid: String.t() | nil,
          traffic_signal_event_id: non_neg_integer,
          event_type: String.t(),
          event_time: DateTime.t(),
          event_geo_node: non_neg_integer,
          vehicle_id: String.t(),
          route_id: String.t(),
          approach_direction: 0..359,
          latitude: float,
          longitude: float,
          deviation_from_schedule: integer,
          bus_load: non_neg_integer,
          distance: non_neg_integer
        }

  @spec from_tsp_map(map) :: {:ok, t} | {:error, any}

  def from_tsp_map(map) when is_map(map) do
    {:ok, datetime, _} = DateTime.from_iso8601(map.event_time)

    tsp = %__MODULE__{
      guid: map.guid,
      traffic_signal_event_id: map.traffic_signal_event_id,
      event_type: map.event_type,
      event_time: datetime,
      event_geo_node: map.event_geo_node,
      vehicle_id: map.vehicle_id,
      route_id: map.route_id,
      approach_direction: map.approach_direction,
      latitude: map.latitude,
      longitude: map.longitude,
      deviation_from_schedule: map.deviation_from_schedule,
      bus_load: map.bus_load,
      distance: map.distance
    }

    {:ok, tsp}
  rescue
    error ->
      {:error, error}
  end
end
