defmodule TrainLoc.Input.APIFetcher do
  @moduledoc """
  Starts and maintains a connection to the Keolis event stream, which reports
  vehicle assignment information. The events are sent to `TrainLoc.Manager` for
  processing.
  """

  alias TrainLoc.Input.ServerSentEvent

  use GenServer

  require Logger

  import TrainLoc.Utilities.ConfigHelpers

  # Client functions
  def start_link(args) do
    url = Keyword.fetch!(args, :url)
    GenServer.start_link(__MODULE__, url, args)
  end

  # Server functions
  defstruct [:url, send_to: TrainLoc.Manager, buffer: "", connected?: false]

  def init(url) do
    state = %__MODULE__{
      url: url}
    if config(APIFetcher, :connect_at_startup?), do: send(self(), :connect)
    {:ok, state}
  end

  def handle_info({:configure, new_state}, state) when is_map(new_state) do
    {:noreply, Enum.reduce(Map.keys(new_state), state, &Map.put(&2, &1, new_state[&1]))}
  end
  def handle_info(:connect, state) do
    url = compute_url(state)
    Logger.debug(fn -> "#{__MODULE__} requesting #{url}" end)
    headers = [
      {"Accept", "text/event-stream"}
    ]
    {:ok, _} = HTTPoison.get(
      url, headers,
      recv_timeout: 60_000,
      stream_to: self())
    {:noreply, state}
  end
  def handle_info(%HTTPoison.AsyncStatus{code: 200}, state) do
    Logger.debug(fn -> "#{__MODULE__} connected" end)
    {:noreply, state}
  end
  def handle_info(%HTTPoison.AsyncHeaders{}, state) do
    {:noreply, state}
  end
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    buffer = state.buffer <> chunk
    event_binaries = String.split(buffer, "\n\n")
    {event_binaries, [buffer]} = Enum.split(event_binaries, -1)
    events = Enum.map(event_binaries, &ServerSentEvent.from_string/1)
    unless events == [] do
      Logger.info fn -> "#{__MODULE__} received #{length events} events" end
      for event <- events do
        Logger.debug(fn ->
          inspect(event, limit: :infinity, printable_limit: :infinity)
        end)
      end
      send(state.send_to, {:events, events})
    end

    state = %{state | buffer: buffer}
    {:noreply, state}
  end
  def handle_info(%HTTPoison.Error{reason: reason}, state) do
    Logger.error fn -> "#{__MODULE__} HTTP error: #{inspect reason}" end
    state = %{state | buffer: ""}
    send self(), :connect
    {:noreply, state}
  end
  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    Logger.info fn -> "#{__MODULE__} disconnected, reconnecting..." end
    state = %{state | buffer: ""}
    send self(), :connect
    {:noreply, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, {:error, "Unknown callback."}, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end


  defp compute_url(%{url: {m, f, a}}) do
    apply(m, f, a)
  end
  defp compute_url(%{url: url}) when is_binary(url) do
    url
  end
end
