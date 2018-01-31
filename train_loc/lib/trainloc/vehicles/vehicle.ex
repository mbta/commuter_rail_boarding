defmodule TrainLoc.Vehicles.Vehicle do
  @moduledoc """
  Functions for working with individual vehicles.
  """

  alias TrainLoc.Utilities.Time

  @enforce_keys [:vehicle_id]
  defstruct [
    :vehicle_id,
    timestamp: 0,
    block: 0,
    trip: "0",
    latitude: 0.0,
    longitude: 0.0,
    heading: 0,
    speed: 0,
    fix: 0
  ]

  @type t :: %__MODULE__{
    vehicle_id: non_neg_integer,
    timestamp: NaiveDateTime.t,
    block: non_neg_integer,
    trip: String.t,
    latitude: float,
    longitude: float,
    heading: 0..359,
    speed: non_neg_integer,
    fix: 1..9
  }

  def from_json_object(obj) do
    from_json_elem({nil, obj})
  end

  @spec from_json_map(map) :: [t]
  def from_json_map(map) do
    Enum.flat_map(map, &from_json_elem/1)
  end

  @spec from_json_elem({String.t, map}) :: t
  defp from_json_elem({_, veh_data = %{"vehicleid" => vehicle_id}}) do
    [%__MODULE__{
      vehicle_id: vehicle_id,
      timestamp:  Time.parse_improper_unix(veh_data["updatetime"]),
      block:      to_string(veh_data["workid"]),
      trip:       process_trip(veh_data["routename"]),
      latitude:   veh_data["latitude"] / 100000,
      longitude:  veh_data["longitude"] / 100000,
      heading:    veh_data["heading"],
      speed:      veh_data["speed"],
      fix:        veh_data["fix"]
    }]
  end
  defp from_json_elem({_, _}), do: []


  @spec process_trip(String.t) :: String.t
  defp process_trip("NO TRAIN SELECTED"), do: "0"
  defp process_trip(""), do: "0"
  defp process_trip(" "), do: "0"
  defp process_trip(routename), do: routename

  @spec log_string(t) :: String.t
  def log_string(v) do
    "#{Time.format_datetime(v.timestamp)} - id:#{v.vehicle_id}, block:#{v.block}, trip:#{v.trip}"
  end

  def active_vehicle?(%__MODULE__{block: "0"}), do: false
  def active_vehicle?(%__MODULE__{trip: "0"}), do: false
  def active_vehicle?(%__MODULE__{trip: "9999"}), do: false
  def active_vehicle?(%__MODULE__{}), do: true
end
