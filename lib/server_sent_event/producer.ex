defmodule ServerSentEvent.Producer do
  @moduledoc """
  A GenStage Producer responsible for emitting ServerSentEvent structs.
  """
  use GenStage
  import StageHelpers
  require Logger

  # Client functions
  def start_link(args) do
    url = Keyword.fetch!(args, :url)
    GenStage.start_link(__MODULE__, url, start_link_opts(args))
  end

  # Server functions
  defstruct [:url, buffer: "", connected?: false, redirect: :no]

  def init(url) do
    state = %__MODULE__{url: url}
    {:producer, state}
  end

  def handle_info(:connect, state) do
    url = compute_url(state)
    Logger.debug(fn -> "#{__MODULE__} requesting #{url}" end)

    headers = [
      {"Accept", "text/event-stream"}
    ]

    {:ok, _} =
      HTTPoison.get(
        url,
        headers,
        recv_timeout: 60_000,
        stream_to: self()
      )

    {:noreply, [], %{state | redirect: :no}}
  end

  def handle_info(%HTTPoison.AsyncStatus{code: 200}, state) do
    Logger.debug(fn -> "#{__MODULE__} connected" end)
    {:noreply, [], state}
  end

  def handle_info(%HTTPoison.AsyncStatus{code: 307}, state) do
    Logger.debug(fn -> "#{__MODULE__} redirecting..." end)
    {:noreply, [], %{state | redirect: :waiting_for_header}}
  end

  def handle_info(
        %HTTPoison.AsyncHeaders{headers: headers},
        %{redirect: :waiting_for_header} = state
      ) do
    {_, location} =
      Enum.find(headers, fn {header, _} ->
        String.downcase(header) == "location"
      end)

    state = %{state | redirect: {:ok, location}}
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
      Logger.info(fn -> "#{__MODULE__} sending #{length(events)} events" end)

      for event <- events do
        Logger.debug(fn ->
          inspect(event, limit: :infinity, printable_limit: :infinity)
        end)
      end
    end

    state = %{state | buffer: buffer}
    {:noreply, events, state}
  end

  def handle_info(%HTTPoison.Error{reason: reason}, state) do
    Logger.error(fn -> "#{__MODULE__} HTTP error: #{inspect(reason)}" end)
    state = %{state | buffer: ""}
    send(self(), :connect)
    {:noreply, [], state}
  end

  def handle_info(%HTTPoison.AsyncEnd{}, state) do
    Logger.info(fn -> "#{__MODULE__} disconnected, reconnecting..." end)
    state = %{state | buffer: "", connected?: false}
    send(self(), :connect)
    {:noreply, [], state}
  end

  def handle_demand(_demand, state) do
    state = maybe_connect(state)
    {:noreply, [], state}
  end

  defp maybe_connect(%{connected?: false} = state) do
    send(self(), :connect)
    %{state | connected?: true}
  end

  defp maybe_connect(state) do
    state
  end

  defp compute_url(%{redirect: {:ok, url}}) do
    url
  end

  defp compute_url(%{url: {m, f, a}}) do
    apply(m, f, a)
  end

  defp compute_url(%{url: url}) when is_binary(url) do
    url
  end
end
