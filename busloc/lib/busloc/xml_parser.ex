defmodule Busloc.XmlParser do
  import SweetXml

  @type xpath_map :: %{
          vehicle_id: String.t(),
          block: String.t(),
          latitude: float,
          longitude: float,
          heading: 0..359,
          timestamp: String.t()
        }

  @spec parse_transitmaster_xml(String.t()) :: xpath_map
  def parse_transitmaster_xml(xml_string) do
    xpath_args = [
      vehicle_id: ~x".//vehicleId/text()"s,
      block: ~x".//blockId/text()"s,
      latitude: ~x".//lat/text()"f,
      longitude: ~x".//lon/text()"f,
      heading: ~x".//heading/text()"i,
      timestamp: ~x".//time/text()"s
    ]

    xpath(xml_string, ~x"//Vehicle"el, xpath_args)
  end
end
