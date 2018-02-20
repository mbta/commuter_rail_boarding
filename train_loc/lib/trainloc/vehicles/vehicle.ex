defmodule TrainLoc.Vehicles.Vehicle do
  @moduledoc """
  Functions for working with individual vehicles.
  """

  alias TrainLoc.Vehicles.Vehicle
  alias TrainLoc.Utilities.Time

  require Logger

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

  @typedoc """
  Vehicle data throughout the app is represented by vehicle structs.

  A vehicle struct includes:

  * `vehicle_id`: unique vehicle identifier
  * `timestamp`: datetime when data was received
  * `block`: represents a series of trips made by a single vehicle in a day
  * `trip`: represents a scheduled commuter rail trip
  * `latitude`: geographic coordinate that specifies the north–south position
    of the vehicle
  * `longitude`: geographic coordinate that specifies the east–west position
    of the vehicle
  * `heading`: compass direction to which the "nose" of the vehicle is pointing,
    its orientation
  * `speed`: the vehicle's speed (miles per hour)
  * `fix`: ID that represents the source of the data.
  """
  @type t :: %__MODULE__{
    vehicle_id: non_neg_integer,
    timestamp: DateTime.t,
    block: non_neg_integer,
    trip: String.t,
    latitude: float,
    longitude: float,
    heading: 0..359,
    speed: non_neg_integer,
    fix: fix_id
  }

  @typedoc """
  Represents the source of the data:

  * `0`: 2D GPS
  * `1`: 3D GPS
  * `2`: 2D DGPS
  * `3`: 3D DGPS
  * `6`: DR (Dead Reckoning)
  * `8`: Degraded DR
  * `9`: Unknown
  """
  @type fix_id :: 1..9

  def from_json_object(obj) do
    from_json_elem({nil, obj})
  end

  @spec from_json_map(map) :: [t]
  def from_json_map(map) do
    Enum.flat_map(map, &from_json_elem/1)
  end

  @spec from_json_elem({any, map}) :: [%Vehicle{}]
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

  @spec log_string(%Vehicle{}) :: String.t
  def log_string(v) do
    "#{Time.format_datetime(v.timestamp)} - id:#{v.vehicle_id}, block:#{v.block}, trip:#{v.trip}"
  end

  def active_vehicle?(%__MODULE__{block: "0"}), do: false
  def active_vehicle?(%__MODULE__{trip: "0"}), do: false
  def active_vehicle?(%__MODULE__{trip: "9999"}), do: false
  def active_vehicle?(%__MODULE__{}), do: true

  @doc """
  Accepts an individual vehicle, logs assignment information for it, and
  returns the vehicle without modifying it.

  Assignment information includes the vehicle ID, the trip, and block the
  vehicle was assigned to.
  """
  @spec log_assignment(Vehicle.t) :: Vehicle.t
  def log_assignment(%{vehicle_id: id, trip: trip, block: block} = vehicle) do
    Logger.info(fn ->
      "Vehicle Assignment - "
      <> "id=#{inspect id} "
      <> "trip=#{inspect trip} "
      <> "block=#{inspect block}"
    end)
    vehicle
  end

end
