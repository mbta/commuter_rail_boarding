defmodule ServerSentEvent.Producer do
  @moduledoc """
  A GenStage Producer responsible for emitting ServerSentEvent structs.
  """
  use GenStage
  require Logger

  # Client functions
  def start_link(args) do
    url = Keyword.fetch!(args, :url)
    opts = if name = Keyword.get(args, :name) do
      [name: name]
    else
      []
    end
    GenStage.start_link(__MODULE__, url, opts)
  end

  # Server functions
  defstruct [:url, buffer: ""]

  def init(url) do
    state = %__MODULE__{
      url: url}
    send self(), :connect
    {:producer, state}
  end

  def handle_info(:connect, state) do
    headers = [
      {"Accept", "text/event-stream"}
    ]
    {:ok, _} = HTTPoison.get(
      compute_url(state), headers,
      recv_timeout: :infinity,
      stream_to: self())
    {:noreply, [], state}
  end
  def handle_info(%HTTPoison.AsyncStatus{code: 200}, state) do
    {:noreply, [], state}
  end
  def handle_info(%HTTPoison.AsyncHeaders{}, state) do
    {:noreply, [], state}
  end
  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    buffer = state.buffer <> chunk
    event_binaries = String.split(buffer, "\n\n")
    {event_binaries, [buffer]} = Enum.split(event_binaries, -1)
    events = Enum.map(event_binaries, &ServerSentEvent.from_string/1)
    unless events == [] do
      Logger.info fn -> "#{__MODULE__} sending #{length events} events" end
      for event <- events do
        Logger.debug(fn -> inspect(event) end)
      end
    end
    state = %{state | buffer: buffer}
    {:noreply, events, state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  defp compute_url(%{url: {m, f, a}}) do
    apply(m, f, a)
  end
  defp compute_url(%{url: url}) when is_binary(url) do
    url
  end
end
