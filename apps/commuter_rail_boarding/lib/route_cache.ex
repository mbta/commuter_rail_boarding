defmodule RouteCache do
  @moduledoc """
  Caches information about GTFS routes for later use.
  """
  use GenServer
  require Logger

  @table __MODULE__.Table

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns the route_id given a long name.

  iex> RouteCache.id_from_long_name("Lowell Line")
  {:ok, "CR-Lowell"}

  iex> RouteCache.id_from_long_name("unknown")
  :error
  """
  @spec id_from_long_name(String.t()) :: {:ok, route_id} | :error
        when route_id: binary
  def id_from_long_name(""), do: :error

  def id_from_long_name(route_name) when is_binary(route_name) do
    do_id_from_long_name(route_name, &insert_and_return/1)
  end

  defp do_id_from_long_name(route_name, fallback_fn) do
    case :ets.lookup(@table, route_name) do
      [{^route_name, route_id}] -> {:ok, route_id}
      [] -> fallback_fn.(route_name)
    end
  end

  defp insert_and_return(route_name) do
    Logger.info("insert_and_return #{inspect(route_name)}")

    with {:ok, response} <-
           HTTPClient.get("/routes/?fields[route]=long_name&type=2"),
         %{status_code: 200, body: body} <- response,
         {:ok, items} <- decode_data(body) do
      _ = :ets.insert(@table, items)
      # try to fetch from the table again
      do_id_from_long_name(route_name, fn _ -> :error end)
    else
      e ->
        Logger.info("insert_and_return error #{inspect(e)}")
        :error
    end
  end

  defp decode_data(%{"data" => data}) when is_list(data) do
    {:ok,
     for route <- data do
       {route["attributes"]["long_name"], route["id"]}
     end}
  end

  defp decode_data(_) do
    :error
  end

  # Server callbacks
  def init(:ok) do
    ets_options = [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ]

    _ = :ets.new(@table, ets_options)
    {:ok, :state}
  end
end
