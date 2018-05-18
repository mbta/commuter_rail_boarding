defmodule Busloc.Vehicle do
  alias Busloc.Utilities.Time, as: BuslocTime

  defstruct [
    :vehicle_id,
    :block,
    :route,
    :latitude,
    :longitude,
    :heading,
    :source,
    :timestamp
  ]

  @type t :: %__MODULE__{
          vehicle_id: String.t(),
          block: String.t() | nil,
          route: String.t() | nil,
          latitude: float,
          longitude: float,
          heading: 0..359,
          source: :transitmaster | :samsara | :saucon | :eyeride,
          timestamp: DateTime.t()
        }

  # 30 minutes
  @stale_vehicle_timeout 1800
  # 5 minutes
  @future_vehicle_timeout 300

  @spec from_transitmaster_map(map, DateTime.t()) :: {:ok, t} | {:error, any}
  def from_transitmaster_map(map, current_time \\ BuslocTime.now()) do
    vehicle = %Busloc.Vehicle{
      vehicle_id: map.vehicle_id,
      block: map.block,
      latitude: map.latitude,
      longitude: map.longitude,
      heading: map.heading,
      source: :transitmaster,
      timestamp: BuslocTime.parse_transitmaster_timestamp(map.timestamp, current_time)
    }

    {:ok, vehicle}
  rescue
    error ->
      {:error, error}
  end

  def from_samsara_json(json) do
    %Busloc.Vehicle{
      vehicle_id: json["name"],
      block: nil,
      latitude: json["latitude"],
      longitude: json["longitude"],
      heading: round(json["heading"]),
      source: :samsara,
      timestamp: DateTime.from_unix!(json["time"], :milliseconds)
    }
  end

  @spec from_eyeride_json(map) :: t
  def from_eyeride_json(json) do
    [latitude, longitude] = json["gps"]["coordinates"]
    {:ok, utc_dt, _} = DateTime.from_iso8601(json["created_at"])

    %__MODULE__{
      vehicle_id: json["bus"],
      route: first_number(json["route_name"]),
      latitude: latitude,
      longitude: longitude,
      heading: 359,
      timestamp: utc_dt,
      source: :eyeride
    }
  end

  defp first_number(<<x::binary-1, _::binary>> = binary) when x in ~w(0 1 2 3 4 5 6 7 8 9) do
    case Integer.parse(binary) do
      {route_id, _} -> Integer.to_string(route_id)
    end
  end

  defp first_number(<<_::binary-1, rest::binary>>) do
    first_number(rest)
  end

  defp first_number(_) do
    nil
  end

  @doc """
  Returns a vehicle.
  """
  @spec from_saucon_json_vehicle(map, String.t()) :: t
  def from_saucon_json_vehicle(json, route_id) do
    %Busloc.Vehicle{
      vehicle_id: "saucon" <> json["name"],
      route: route_id,
      latitude: json["lat"],
      longitude: json["lon"],
      heading: round(json["course"]),
      source: :saucon,
      timestamp: DateTime.from_unix!(json["timestamp"], :milliseconds)
    }
  end

  for {saucon_route_number, route_id} <- Application.get_env(:busloc, Saucon)[:route_ids] do
    defp saucon_route_translate(unquote(saucon_route_number)), do: unquote(route_id)
  end

  defp saucon_route_translate(_), do: nil

  @doc """
  Returns a list of vehicles on a particular route.
  """
  @spec from_saucon_json(map) :: [t]
  def from_saucon_json(json) do
    Enum.map(
      json["vehiclesOnRoute"],
      &from_saucon_json_vehicle(&1, saucon_route_translate(json["routeId"]))
    )
  end

  @doc """
  Returns whether the vehicle has a valid time (relative to the given time).

  Currently, we allow vehicles to be #{@stale_vehicle_timeout / 60} minutes
  in the past and #{@future_vehicle_timeout / 60} minutes in the future.


      iex> one_second = DateTime.from_unix!(1)
      iex> thirty_minutes = DateTime.from_unix!(1900)
      iex> vehicle = %Vehicle{timestamp: one_second}
      iex> validate_time(vehicle, one_second)
      :ok
      iex> validate_time(vehicle, thirty_minutes)
      {:error, :stale}

      iex> one_second = DateTime.from_unix!(1)
      iex> ten_minutes = DateTime.from_unix!(400)
      iex> future_vehicle = %Vehicle{timestamp: ten_minutes}
      iex> validate_time(future_vehicle, one_second)
      {:error, :future}
  """
  @spec validate_time(t, DateTime.t()) :: :ok | {:error, :stale | :future}
  def validate_time(%__MODULE__{timestamp: timestamp}, now) do
    diff = DateTime.diff(now, timestamp)

    cond do
      diff > @stale_vehicle_timeout ->
        {:error, :stale}

      -diff > @future_vehicle_timeout ->
        {:error, :future}

      true ->
        :ok
    end
  end

  @spec log_line(t, DateTime.t()) :: String.t()
  def log_line(%__MODULE__{} = vehicle, now) do
    log_parts =
      vehicle
      |> Map.from_struct()
      |> log_line_time_status(validate_time(vehicle, now))
      |> Enum.map(&log_line_item/1)
      |> Enum.join(" ")

    "Vehicle - #{log_parts}"
  end

  defp log_line_time_status(map, :ok) do
    map
  end

  defp log_line_time_status(map, {:error, status}) do
    Map.put(map, :invalid_time, status)
  end

  defp log_line_item({key, value}) when is_binary(value) do
    "#{key}=#{inspect(value)}"
  end

  defp log_line_item({key, %DateTime{} = value}) do
    "#{key}=#{DateTime.to_iso8601(value)}"
  end

  defp log_line_item({key, value}) do
    "#{key}=#{value}"
  end
end
