defmodule TripCache do
  @moduledoc """
  Caches information about GTFS trips for later use.
  """
  use GenServer
  require Logger

  @table __MODULE__.Table

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns the route_id and direction_id for a trip, or an error
  """
  @spec route_direction_id(trip_id) :: {:ok, route_id, direction_id} | :error
    when trip_id: binary, route_id: binary, direction_id: 0 | 1
  def route_direction_id(""), do: :error
  def route_direction_id(trip_id) when is_binary(trip_id) do
    case :ets.lookup(@table, {:trip, trip_id}) do
      [{_, route_id, direction_id, _, _}] ->
        {:ok, route_id, direction_id}
      [] ->
        with {:ok, route_id, direction_id, _, _} <- insert_and_return_trip_info(trip_id) do
          {:ok, route_id, direction_id}
        end
    end
  end

  @doc """
  Returns the name and headsign for a trip ID"
  """
  def trip_name_headsign(""), do: :error
  def trip_name_headsign(trip_id) when is_binary(trip_id) do
    case :ets.lookup(@table, {:trip, trip_id}) do
      [{_, _, _, name, headsign}] ->
        {:ok, name, headsign}
      [] ->
        with {:ok, _, _, name, headsign} <- insert_and_return_trip_info(trip_id) do
          {:ok, name, headsign}
        end
    end
  end

  @doc """
  Returns the trip_id and direction_id for a route + name, or an error
  """
  @spec route_trip_name_to_id(route_id, trip_name) ::
  {:ok, trip_id, direction_id} | :error
  when route_id: binary, trip_name: binary, trip_id: binary,
    direction_id: 0 | 1
  def route_trip_name_to_id(route_id, trip_name) when is_binary(route_id) and is_binary(trip_name) do
    do_route_trip_name_to_id(
      route_id,
      trip_name,
      fn {route_id, trip_name} ->
        insert_and_return_trip_id(route_id, trip_name)
      end)
  end

  defp insert_and_return_trip_info(trip_id) do
    with {:ok, response} <- HTTPClient.get(
           "/trips/#{trip_id}", [], params: [{"fields[trip]", "direction_id,name,headsign"}]),
         %{status_code: 200, body: body} <- response,
         {:ok, route_id, direction_id, trip_name, trip_headsign} <- decode_single_trip(body) do
      _ = :ets.insert_new(@table, {{:trip, trip_id}, route_id, direction_id, trip_name, trip_headsign})
      {:ok, route_id, direction_id, trip_name, trip_headsign}
    else
      _ -> :error
    end
  end

  defp decode_single_trip(%{"data" => %{"relationships" => relationships, "attributes" => attributes}}) do
    {:ok,
     relationships["route"]["data"]["id"],
     attributes["direction_id"],
     attributes["name"],
     attributes["headsign"]}
  end
  defp decode_single_trip(%{"data" => []}) do
    :error
  end

  defp do_route_trip_name_to_id(route_id, trip_name, fallback_fn) do
    case :ets.lookup(@table, {:route, route_id, trip_name}) do
      [{_, trip_id, direction_id}] -> {:ok, trip_id, direction_id}
      [] -> fallback_fn.({route_id, trip_name})
    end
  end

  defp insert_and_return_trip_id(route_id, trip_name) do
    with {:ok, response} <- HTTPClient.get(
           "/trips/", [],
           params: ["fields[trip]": "name,direction_id",
                    route: route_id,
                    date: Date.to_iso8601(DateHelpers.service_date)]),
         %{status_code: 200, body: body} <- response,
         {:ok, items} <- decode_trips(body) do
      _ = :ets.insert(@table, items)
      do_route_trip_name_to_id(route_id, trip_name, fn _ -> :error end)
    end
  end

  defp decode_trips(%{"data" => data}) when is_list(data) do
    {:ok,
     for trip <- data do
       key = {:route,
              trip["relationships"]["route"]["data"]["id"],
              trip["attributes"]["name"]}
       {key, trip["id"], trip["attributes"]["direction_id"]}
     end
    }
  end
  defp decode_trips(_) do
    :error
  end

  # Server callbacks
  def init(:ok) do
    ets_options = [:set, :public, :named_table,
                   {:read_concurrency, true}, {:write_concurrency, true}]
    _ = :ets.new(@table, ets_options)
    timeout = DateHelpers.seconds_until_next_service_date
    {:ok, :state, :timer.seconds(timeout)}
  end

  def handle_info(:timeout, state) do
    Logger.info fn ->
      "#{__MODULE__} expiring cache"
    end
    :ets.delete_all_objects(@table)
    timeout = DateHelpers.seconds_until_next_service_date
    {:noreply, state, :timer.seconds(timeout)}
  end
end
