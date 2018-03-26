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
          timestamp: non_neg_integer
        }

  def from_transitmaster_map(map) do
    %Busloc.Vehicle{
      vehicle_id: map.vehicle_id,
      block: map.block,
      latitude: map.latitude,
      longitude: map.longitude,
      heading: map.heading,
      source: :transitmaster,
      timestamp: BuslocTime.parse_transitmaster_timestamp(map.timestamp)
    }
  end
end
