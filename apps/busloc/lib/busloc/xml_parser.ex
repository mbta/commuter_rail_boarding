defmodule Busloc.XmlParser do
  import SweetXml
  require Logger

  @type xpath_map :: %{
          vehicle_id: String.t(),
          route: String.t(),
          trip: String.t(),
          block: String.t(),
          latitude: float,
          longitude: float,
          heading: 0..359,
          timestamp: String.t()
        }

  @spec parse_transitmaster_xml(String.t()) :: {:ok, [xpath_map]} | {:error, :invalid_xml}
  def parse_transitmaster_xml(xml_string) do
    parsed_doc = parse(xml_string, quiet: true)

    with array_element when not is_nil(array_element) <- xpath(parsed_doc, ~x"/ArrayOfVehicle"e) do
      vehicle_elements = xpath(array_element, ~x"./Vehicle"el)

      maps =
        for element <- vehicle_elements,
            {:ok, map} <- [vehicle_xpath(element)] do
          map
        end

      {:ok, maps}
    else
      _ ->
        {:error, :invalid_transitmaster}
    end
  catch
    :exit, _ ->
      {:error, :invalid_xml}
  end

  defp vehicle_xpath(element) do
    xpath_args = [
      vehicle_id: ~x".//vehicleId/text()"s,
      route: ~x".//routeId/text()"s,
      trip: ~x".//trip/text()"s,
      block: ~x".//blockId/text()"s,
      latitude: ~x".//lat/text()"f,
      longitude: ~x".//lon/text()"f,
      heading: ~x".//heading/text()"i,
      timestamp: ~x".//time/text()"s
    ]

    map = xmap(element, xpath_args)
    {:ok, map}
  rescue
    error ->
      Logger.warn(fn ->
        "#{__MODULE__} unable to parse vehicle#{inspect(element)}: #{inspect(error)}"
      end)

      :error
  end
end
