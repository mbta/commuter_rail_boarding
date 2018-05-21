defmodule Busloc.Encoder.NextbusXml do
  @behaviour Busloc.Encoder
  import XmlBuilder

  @typedoc """
  name, attribute (NextBus spec doesn't have any), value
  """
  @type element :: {atom, nil, String.t() | [element]}

  @impl Busloc.Encoder
  def encode(vehicles) do
    doc = document(:history, [element(:vehicles, Enum.map(vehicles, &vehicle_to_element/1))])

    generate(doc)
  end

  @spec vehicle_to_element(Busloc.Vehicle.t()) :: element
  def vehicle_to_element(vehicle) do
    element(:vehicle, [
      element(:id, vehicle.vehicle_id),
      element(:date, nextbus_datetime(vehicle.timestamp)),
      element(:lat, vehicle.latitude),
      element(:lon, vehicle.longitude),
      element(:direction, vehicle.heading),
      element(:block, vehicle.block),
      element(:vehstatus, "f")
    ])
  end

  defp nextbus_datetime(timestamp) do
    # NextBus needs UTC
    timestamp
    |> Timex.to_datetime("Etc/UTC")
    |> Timex.format!("{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end
end
