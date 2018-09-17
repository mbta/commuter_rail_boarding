defmodule Busloc.Vehicle do
  alias Busloc.Utilities.Time, as: BuslocTime

  defstruct [
    :vehicle_id,
    :block,
    :route,
    :trip,
    :latitude,
    :longitude,
    :heading,
    :source,
    :timestamp,
    :start_date
  ]

  @type t :: %__MODULE__{
          vehicle_id: String.t(),
          block: String.t() | nil,
          route: String.t() | nil,
          trip: String.t() | nil,
          latitude: float | nil,
          longitude: float | nil,
          heading: 0..359,
          source: :transitmaster | :samsara | :saucon | :eyeride,
          timestamp: DateTime.t(),
          start_date: Date.t() | nil
        }

  # 30 minutes
  @stale_vehicle_timeout 1800
  # 5 minutes
  @future_vehicle_timeout 300

  @spec from_transitmaster_map(map, DateTime.t()) :: {:ok, t} | {:error, any}
  def from_transitmaster_map(map, current_time \\ BuslocTime.now()) do
    vehicle = %Busloc.Vehicle{
      vehicle_id: map.vehicle_id,
      route: nil_if_equal(map.route, ""),
      trip: nil_if_equal(map.trip, "0"),
      block: map.block,
      latitude: nil_if_equal(map.latitude, 0),
      longitude: nil_if_equal(map.longitude, 0),
      heading: map.heading,
      source: :transitmaster,
      timestamp: BuslocTime.parse_transitmaster_timestamp(map.timestamp, current_time),
      start_date: transitmaster_start_date(map.service_date)
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
      latitude: nil_if_equal(json["latitude"], 0),
      longitude: nil_if_equal(json["longitude"], 0),
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

  defp nil_if_equal(input, input), do: nil
  defp nil_if_equal(input, _), do: input

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
  Parses the TransitMaster service_date into a GTFS-Realtime start_date (or nil)

  ## Examples

      iex> transitmaster_start_date("20180430")
      ~D[2018-04-30]

      iex> transitmaster_start_date("7/25/2018 12:00:00 AM")
      ~D[2018-07-25]

      iex> transitmaster_start_date("1/1/0001 12:00:00 AM")
      nil

      iex> transitmaster_start_date(nil)
      nil
  """
  @spec transitmaster_start_date(String.t()) :: Date.t() | nil
  def transitmaster_start_date(<<year::binary-4, month::binary-2, day::binary-2>>) do
    transitmaster_start_date(year, month, day)
  end

  def transitmaster_start_date("1/1/0001" <> _) do
    nil
  end

  def transitmaster_start_date(
        <<month::binary-1, ?/, day::binary-1, ?/, year::binary-4, _::binary>>
      ) do
    # 9/1/2018
    transitmaster_start_date(year, month, day)
  end

  def transitmaster_start_date(
        <<month::binary-1, ?/, day::binary-2, ?/, year::binary-4, _::binary>>
      ) do
    # 9/10/2018
    transitmaster_start_date(year, month, day)
  end

  def transitmaster_start_date(
        <<month::binary-2, ?/, day::binary-1, ?/, year::binary-4, _::binary>>
      ) do
    # 10/1/2018
    transitmaster_start_date(year, month, day)
  end

  def transitmaster_start_date(
        <<month::binary-2, ?/, day::binary-2, ?/, year::binary-4, _::binary>>
      ) do
    # 10/10/2018
    transitmaster_start_date(year, month, day)
  end

  def transitmaster_start_date(nil) do
    nil
  end

  defp transitmaster_start_date(year, month, day) do
    Date.from_erl!({String.to_integer(year), String.to_integer(month), String.to_integer(day)})
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
    vehicle
    |> log_line_time_status(validate_time(vehicle, now))
    |> log_age(now)
    |> Busloc.LogHelper.log_struct()
  end

  defp log_line_time_status(map, :ok) do
    map
  end

  defp log_line_time_status(map, {:error, status}) do
    Map.put(map, :invalid_time, status)
  end

  defp log_age(%{timestamp: timestamp} = map, now) do
    Map.put(map, :age, DateTime.to_unix(now) - DateTime.to_unix(timestamp))
  end
end
