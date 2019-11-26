defmodule TrainLoc.Input.APIFetcher do
  @moduledoc """
  Starts and maintains a connection to the Keolis event stream, which reports
  vehicle assignment information. The events are sent to `TrainLoc.Manager` for
  processing.
  """

  alias TrainLoc.Input.ServerSentEvent
  alias TrainLoc.Logging
  use GenServer

  require Logger

  import TrainLoc.Utilities.ConfigHelpers

  # Client functions
  def start_link(args) do
    url = Keyword.fetch!(args, :url)
    GenServer.start_link(__MODULE__, url, args)
  end

  @doc """
  Awaits a reply.
  """
  def await(pid \\ __MODULE__) do
    GenServer.call(pid, :await)
  end

  # Server functions
  defstruct url: nil,
            send_to: TrainLoc.Manager,
            buffer: "",
            connected?: false

  def init(url_or_mfa) do
    state = %__MODULE__{
      url: url_or_mfa
    }

    if config(APIFetcher, :connect_at_startup?), do: send(self(), :connect)
    {:ok, state}
  end

  def handle_info({:configure, new_state}, state) when is_map(new_state) do
    {:noreply,
     Enum.reduce(Map.keys(new_state), state, &Map.put(&2, &1, new_state[&1]))}
  end

  def handle_info(:connect, state) do
    url = compute_url(state)
    Logger.debug(fn -> "#{__MODULE__} requesting #{url}" end)

    headers = [
      {"Accept", "text/event-stream"}
    ]

    httpoison_opts = [
      recv_timeout: 60_000,
      stream_to: self()
    ]

    http_connect(state, [url, headers, httpoison_opts])
  end

  def handle_info(%HTTPoison.AsyncStatus{code: 200}, state) do
    Logger.debug(fn -> "#{__MODULE__} connected" end)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncStatus{code: code}, state) when code != 200 do
    log_keolis_error(state, fn -> "HTTP status #{code}" end)
    state = %{state | buffer: ""}
    send(self(), :connect)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncHeaders{}, state) do
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    {event_blocks, buffer} =
      extract_event_blocks_from_buffer(state.buffer <> chunk)

    state = %{state | buffer: buffer}

    event_blocks
    |> parse_events_from_blocks
    |> send_events_for_processing(state.send_to)

    {:noreply, state}
  end

  def handle_info(%HTTPoison.Error{reason: reason}, state) do
    log_keolis_error(state, fn -> "HTTPoison.Error #{inspect(reason)}" end)
    state = %{state | buffer: ""}
    send(self(), :connect)
    {:noreply, state}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    Logger.info(fn -> "Keolis API Disconnected. Retrying..." end)
    state = %{state | buffer: ""}
    send(self(), :connect)
    {:noreply, state}
  end

  def handle_call(:await, _from, state) do
    {:reply, true, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, {:error, "Unknown callback."}, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def http_connect(
        state,
        args,
        connect_fn \\ &HTTPoison.get/3,
        timeout \\ 5_000
      ) do
    case apply(connect_fn, args) do
      {:ok, _} ->
        :ok

      {:error, error} ->
        log_keolis_error(state, fn ->
          "Error while connecting: #{inspect(error)}"
        end)

        Process.send_after(self(), :connect, timeout)
        :ok
    end

    {:noreply, state}
  end

  def extract_event_blocks_from_buffer(buffer) do
    # separate events
    # last one is new_buffer
    buffer
    |> String.split("\n\n")
    |> Enum.split(-1)
    |> case do
      {events, [new_buffer]} -> {events, new_buffer}
    end
  end

  defp compute_url(%{url: {m, f, a}}) do
    apply(m, f, a)
  end

  defp compute_url(%{url: url}) when is_binary(url) do
    url
  end

  def log_empty_events_error do
    log_keolis_error("No events parsed")
  end

  def log_parsing_error(errors) when is_list(errors) do
    Enum.each(errors, &log_parsing_error/1)
  end

  def log_parsing_error(error) when is_map(error) do
    error
    |> Map.put(:error_type, "Parsing Error")
    |> log_keolis_error
  end

  def send_events_for_processing(events, send_to) when is_list(events) do
    Logger.info(fn -> "#{__MODULE__} received #{length(events)} events" end)

    for event <- events do
      Logger.debug(fn ->
        inspect(event, limit: :infinity, printable_limit: :infinity)
      end)
    end

    send_events_to(events, send_to)
  end

  defp send_events_to([], _destination) do
    # return {:events, []} to keep return api/shape consistent
    {:events, []}
  end

  defp send_events_to(events, destination) do
    send(destination, {:events, events})
  end

  def log_keolis_error(fields) when is_map(fields) do
    Logger.error(fn ->
      Logging.log_string("Keolis API Failure", fields)
    end)
  end

  def log_keolis_error(reason) when is_binary(reason) do
    log_keolis_error(%{error_type: reason})
  end

  def parse_events_from_blocks([]) do
    log_empty_events_error()
    []
  end

  def parse_events_from_blocks(event_blocks) when is_list(event_blocks) do
    Enum.map(event_blocks, &ServerSentEvent.from_string/1)
  end

  defp log_keolis_error(state, message_fn) do
    Logger.error(fn ->
      "#{__MODULE__} Keolis API Failure - url=#{inspect(state.url)} error_type=#{
        inspect(message_fn.())
      }"
    end)
  end
end
