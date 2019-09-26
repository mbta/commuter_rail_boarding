defmodule Busloc.XmlParser do
  import SweetXml
  require Logger

  @type tm_xpath_map :: %{
          vehicle_id: String.t(),
          route: String.t(),
          trip: String.t(),
          block: String.t(),
          run: String.t(),
          overload_id: integer,
          overload_offset: integer,
          latitude: float,
          longitude: float,
          heading: 0..359,
          timestamp: String.t(),
          service_date: String.t()
        }

  @type tsp_xpath_map :: %{
          guid: String.t(),
          traffic_signal_event_id: non_neg_integer,
          event_type: String.t(),
          event_time: String.t(),
          event_geo_node: String.t(),
          vehicle_id: String.t(),
          route_id: String.t(),
          approach_direction: 0..359,
          latitude: float,
          longitude: float,
          deviation_from_schedule: integer,
          bus_load: non_neg_integer,
          distance: non_neg_integer
        }

  @spec parse_transitmaster_xml(String.t()) :: {:ok, [tm_xpath_map]} | {:error, :invalid_xml}
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
      run: ~x".//runId/text()"s,
      overload_id: ~x".//overloadId/text()"i,
      overload_offset: ~x".//overloadOffset/text()"i,
      latitude: ~x".//lat/text()"f,
      longitude: ~x".//lon/text()"f,
      heading: ~x".//heading/text()"i,
      timestamp: ~x".//time/text()"s,
      service_date: ~x".//serviceDate/text()"s
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

  @spec parse_tsp_xml(String.t()) :: tsp_xpath_map | {:error, :invalid_xml}
  def parse_tsp_xml(xml_string) do
    tsp_xpath_args = [
      event_type: ~x"local-name()"s,
      guid: ~x".//GUID/text()"s,
      traffic_signal_event_id: ~x".//TRAFFIC_SIGNAL_EVENT_ID/text()"i,
      event_time: ~x".//EVENT_TIME/text()"s,
      event_geo_node: ~x".//EVENT_GEO_NODE_ABBR/text()"s,
      vehicle_id: ~x".//VEHICLE_ID/text()"s,
      route_id: ~x".//ROUTE_ABBR/text()"s,
      approach_direction: ~x".//APPROACH_DIRECTION/text()"i,
      latitude: ~x".//VEHICLE_LATITUDE/text()"f,
      longitude: ~x".//VEHICLE_LONGITUDE/text()"f,
      deviation_from_schedule: ~x".//DEVIATION_FROM_SCHEDULE/text()"i,
      bus_load: ~x".//BUS_LOAD/text()"i,
      distance: ~x".//DISTANCE/text()"i
    ]

    xmap(xml_string, tsp_xpath_args)
  catch
    :exit, _ ->
      {:error, :invalid_xml}
  end
end
