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

  @spec parse_transitmaster_xml(String.t()) :: {:ok, [xpath_map]} | {:error, :invalid_xml}
  def parse_transitmaster_xml(xml_string) do
    xpath_args = [
      vehicle_id: ~x".//vehicleId/text()"s,
      block: ~x".//blockId/text()"s,
      latitude: ~x".//lat/text()"f,
      longitude: ~x".//lon/text()"f,
      heading: ~x".//heading/text()"i,
      timestamp: ~x".//time/text()"s
    ]

    parsed_doc = parse(xml_string, quiet: true)

    maps = xpath(parsed_doc, ~x"//Vehicle"el, xpath_args)
    {:ok, maps}
  catch
    :exit, _ ->
      {:error, :invalid_xml}
  end
end
