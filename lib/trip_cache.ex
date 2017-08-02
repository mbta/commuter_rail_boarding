defmodule TripCache do
  use GenServer

  @table __MODULE__.Table

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

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
    _ = :ets.new(@table, [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}])
    {:ok, :state}
  end
end
