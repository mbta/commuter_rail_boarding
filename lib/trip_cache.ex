defmodule TripCache do
  @moduledoc """
  Caches information about GTFS trips for later use.
  """
  use GenServer

  @table __MODULE__.Table

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns the route_id and direction_id for a trip, or an error
  """
  @spec route_direction_id(trip_id) :: {:ok, route_id, direction_id} | :error
  when trip_id: binary, route_id: binary, direction_id: 0 | 1
  def route_direction_id(trip_id) when is_binary(trip_id) do
    case :ets.lookup(@table, trip_id) do
      [{^trip_id, route_id, direction_id}] -> {:ok, route_id, direction_id}
      [] -> insert_and_return(trip_id)
    end
  end

  defp insert_and_return(trip_id) do
    with {:ok, response} <- HTTPoison.get(
           "https://api.mbtace.com/trips/#{trip_id}", [], params: [{"fields[trip]", "direction_id"}]),
         %{status_code: 200, body: body} <- response,
         {:ok, parsed} <- Poison.decode(body),
         {:ok, route_id, direction_id} <- decode_data(parsed) do
      _ = :ets.insert_new(@table, {trip_id, route_id, direction_id})
      {:ok, route_id, direction_id}
    else
      _ -> :error
    end
  end

  defp decode_data(%{"data" => %{"relationships" => relationships, "attributes" => attributes}}) do
    {:ok,
     relationships["route"]["data"]["id"],
     attributes["direction_id"]}
  end
  defp decode_data(%{"data" => []}) do
    :error
  end

  # Server callbacks
  def init(:ok) do
    ets_options = [:set, :public, :named_table,
                   {:read_concurrency, true}, {:write_concurrency, true}]
    _ = :ets.new(@table, ets_options)
    {:ok, :state}
  end
end
