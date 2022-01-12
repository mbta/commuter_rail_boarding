defmodule TrainLoc.Vehicles.Vehicle do
  @moduledoc """
  Functions for working with individual vehicles.
  """

  alias TrainLoc.Utilities.Time, as: TrainLocTime
  alias TrainLoc.Vehicles.Vehicle

  require Logger

  @enforce_keys [:vehicle_id]
  defstruct [
    :vehicle_id,
    timestamp: DateTime.from_naive!(~N[1970-01-01T00:00:00], "Etc/UTC"),
    block: "",
    trip: "",
    latitude: 0.0,
    longitude: 0.0,
    heading: 0,
    speed: 0
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
  """
  @type t :: %__MODULE__{
          vehicle_id: non_neg_integer,
          timestamp: DateTime.t(),
          block: String.t(),
          trip: String.t(),
          latitude: float | nil,
          longitude: float | nil,
          heading: 0..359,
          speed: non_neg_integer
        }

  def from_json_object(obj) do
    from_json_elem({nil, obj})
  end

  @spec from_json_map(map) :: [t]
  def from_json_map(map) do
    Enum.flat_map(map, &from_json_elem/1)
  end

  @spec from_json_elem({any, map}) :: [t()]
  defp from_json_elem({_, veh_data = %{"VehicleID" => _vehicle_id}}) do
    [from_json(veh_data)]
  end

  defp from_json_elem({_, _}), do: []

  @spec from_json(map) :: t()
  def from_json(veh_data) when is_map(veh_data) do
    %__MODULE__{
      vehicle_id: veh_data["VehicleID"],
      timestamp: TrainLocTime.parse_improper_iso(veh_data["Update Time"]),
      block: process_trip_block(veh_data["WorkID"]),
      trip: process_trip_block(veh_data["TripID"]),
      latitude: process_lat_long(veh_data["Latitude"]),
      longitude: process_lat_long(veh_data["Longitude"]),
      heading: veh_data["Heading"],
      speed: veh_data["Speed"]
    }
  end

  defp process_lat_long(0), do: nil
  defp process_lat_long(lat_long), do: lat_long

  defp process_trip_block(trip_or_block) when is_integer(trip_or_block) do
    trip_or_block
    |> Integer.to_string()
    |> String.pad_leading(3, ["0"])
  end

  defp process_trip_block(_), do: nil

  def active_vehicle?(%__MODULE__{block: "000"}), do: false
  def active_vehicle?(%__MODULE__{trip: "000"}), do: false
  def active_vehicle?(%__MODULE__{}), do: true

  @doc """
  Logs all available vehicle data for a single vehicle and returns it without
  modifying it.

  """
  @spec log_vehicle(Vehicle.t()) :: Vehicle.t()
  def log_vehicle(vehicle) do
    _ =
      Logger.debug(fn ->
        Enum.reduce(Map.from_struct(vehicle), "Vehicle - ", fn {key, value}, acc ->
          acc <> format_key_value_pair(key, value)
        end)
      end)

    vehicle
  end

  defp format_key_value_pair(key, %DateTime{} = value) do
    format_key_value_pair(key, DateTime.to_iso8601(value))
  end

  defp format_key_value_pair(key, value) do
    "#{key}=#{value} "
  end
end
