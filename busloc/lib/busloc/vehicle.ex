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

  def from_transitmaster_map(map, current_time \\ BuslocTime.now()) do
    %Busloc.Vehicle{
      vehicle_id: map.vehicle_id,
      block: map.block,
      latitude: map.latitude,
      longitude: map.longitude,
      heading: map.heading,
      source: :transitmaster,
      timestamp: BuslocTime.parse_transitmaster_timestamp(map.timestamp, current_time)
    }
  end

  @spec log_line(t) :: String.t()
  def log_line(%__MODULE__{} = vehicle) do
    log_parts =
      vehicle
      |> Map.from_struct()
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
