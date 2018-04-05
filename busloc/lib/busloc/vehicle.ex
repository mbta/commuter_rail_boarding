defmodule Busloc.Vehicle do
  alias Busloc.Utilities.Time, as: BuslocTime

  defstruct [
    :vehicle_id,
    :block,
    :latitude,
    :longitude,
    :heading,
    :source,
    :timestamp
  ]

  @type t :: %__MODULE__{
          vehicle_id: String.t(),
          block: String.t(),
          latitude: float,
          longitude: float,
          heading: 0..359,
          source: :transitmaster | :samsara | :saucon,
          timestamp: DateTime.t()
        }

  # 30 minutes
  @stale_vehicle_timeout 1800

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

  @doc """
  Returns whether the vehicle is stale (relative to the given time).

      iex> one_second = DateTime.from_unix!(1)
      iex> thirty_minutes = DateTime.from_unix!(1900)
      iex> vehicle = %Vehicle{timestamp: one_second}
      iex> stale?(vehicle, one_second)
      false
      iex> stale?(vehicle, thirty_minutes)
      true
  """
  @spec stale?(t, DateTime.t()) :: boolean
  def stale?(%__MODULE__{timestamp: timestamp}, now) do
    diff = DateTime.diff(now, timestamp)
    diff > @stale_vehicle_timeout
  end

  @spec log_line(t, DateTime.t()) :: String.t()
  def log_line(%__MODULE__{} = vehicle, now) do
    log_parts =
      vehicle
      |> Map.from_struct()
      |> Map.put(:stale, stale?(vehicle, now))
      |> Enum.map(&log_line_item/1)
      |> Enum.join(" ")

    "Vehicle - #{log_parts}"
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
