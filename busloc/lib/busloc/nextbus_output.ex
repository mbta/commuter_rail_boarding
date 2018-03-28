defmodule Busloc.NextbusOutput do
  import XmlBuilder

  @typedoc """
  name, attribute (NextBus spec doesn't have any), value
  """
  @type element :: {atom, nil, String.t() | [element]}

  @spec create_nextbus_xml_file([Busloc.Vehicle.t()]) :: [Busloc.Vehicle.t()]
  def create_nextbus_xml_file(vehicles) do
    File.open!("nextbus.xml", [:write, :utf8])
    |> IO.write(to_nextbus_xml(vehicles))

    vehicles
  end

  @spec to_nextbus_xml([Busloc.Vehicle.t()]) :: String.t()
  def to_nextbus_xml(vehicles) do
    doc(:history, [element(:vehicles, Enum.map(vehicles, &vehicle_to_element/1))])
  end

  @spec vehicle_to_element(Busloc.Vehicle.t()) :: element
  def vehicle_to_element(vehicle) do
    element(:vehicle, [
      element(:id, vehicle.vehicle_id),
      element(:date, nextbus_datetime(vehicle.timestamp)),
      element(:lat, vehicle.latitude),
      element(:lon, vehicle.longitude),
      element(:direction, vehicle.heading),
      element(:block, vehicle.block)
    ])
  end

  defp nextbus_datetime(timestamp) do
    # NextBus needs UTC
    timestamp
    |> Timex.to_datetime("Etc/UTC")
    |> Timex.format!("{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s}")
  end
end
