defmodule ScheduleCache do
  @moduledoc """
  Caches information about GTFS schedule for later use.
  """
  use GenServer
  require Logger

  @table __MODULE__.Table
  @six_month_timeout :timer.hours(24 * 30 * 60)

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns the stop_sequence for a trip/stop ID pair.
  """
  @spec stop_sequence(trip_id, stop_id) :: {:ok, non_neg_integer} | :error
        when trip_id: binary, stop_id: binary
  def stop_sequence(trip_id, stop_id)
      when is_binary(trip_id) and is_binary(stop_id) do
    case :ets.lookup(@table, {trip_id, stop_id}) do
      [{_, stop_sequence}] -> {:ok, stop_sequence}
      [] -> insert_and_return_stop_sequence(trip_id, stop_id)
    end
  end

  defp insert_and_return_stop_sequence(trip_id, stop_id) do
    with {:ok, response} <-
           HTTPClient.get(
             "/schedules/",
             [],
             params: [
               trip: trip_id,
               stop: stop_id,
               "fields[schedule]": "stop_sequence"
             ]
           ),
         %{status_code: 200, body: body} <- response,
         {:ok, stop_sequence} <- decode(body) do
      _ = :ets.insert(@table, {{trip_id, stop_id}, stop_sequence})
      # try to fetch from the table again
      {:ok, stop_sequence}
    else
      _ -> :error
    end
  end

  defp decode(%{"data" => [schedule | _]}) do
    {:ok, schedule["attributes"]["stop_sequence"]}
  end

  defp decode(_) do
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
    # we have a timeout after six months so that on the off-chance this runs
    # for a while, we won't use an infinite amount of memory
    schedule_timeout()
    {:ok, :state}
  end

  def handle_info(:timeout, state) do
    _ =
      Logger.info(fn ->
        "#{__MODULE__} expiring cache"
      end)

    :ets.delete_all_objects(@table)
    schedule_timeout()
    {:noreply, state}
  end

  defp schedule_timeout do
    Process.send_after(self(), :timeout, @six_month_timeout)
  end
end
