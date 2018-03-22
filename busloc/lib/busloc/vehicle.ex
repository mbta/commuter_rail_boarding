defmodule Busloc.Vehicle do
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
end
