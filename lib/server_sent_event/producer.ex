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
  defstruct [:url, buffer: "", connected?: false, id: nil, redirect: :no]

  def init(url) do
    state = %__MODULE__{url: url}
    {:producer, state}
  end

  def handle_info(:connect, state) do
    url = compute_url(state)
    state = %{state | redirect: :no}
    Logger.debug(fn -> "#{__MODULE__} requesting #{url}" end)

    headers = [
      {"Accept", "text/event-stream"}
    ]

    case HTTPoison.get(
           url,
           headers,
           recv_timeout: 60_000,
           stream_to: self()
         ) do
      {:ok, %{id: id}} ->
        {:noreply, [], %{state | id: id}}

      {:error, e} ->
        handle_info(e, state)
    end
  end

  def handle_info(%HTTPoison.AsyncStatus{id: id, code: 200}, %{id: id} = state) do
    Logger.debug(fn -> "#{__MODULE__} connected" end)
    {:noreply, [], state}
  end

  def handle_info(%HTTPoison.AsyncStatus{id: id, code: 307}, %{id: id} = state) do
    Logger.debug(fn -> "#{__MODULE__} redirecting..." end)
    {:noreply, [], %{state | redirect: :waiting_for_header}}
  end

  def handle_info(
        %HTTPoison.AsyncHeaders{id: id, headers: headers},
        %{id: id, redirect: :waiting_for_header} = state
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

  def handle_info(
        %HTTPoison.AsyncChunk{id: id, chunk: chunk} = c,
        %{id: id} = state
      ) do
    log_chunk(c)
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

        if event.event == "auth_revoked" do
          # HTTPoison doesn't provide an interface for this, but it does
          # provide the ID we need.
          :hackney.close(c.id)
          send(self(), :connect)
        end
      end
    end

    state = %{state | buffer: buffer}
    {:noreply, events, state}
  end

  def handle_info(%HTTPoison.Error{id: id, reason: reason}, %{id: id} = state) do
    Logger.error(fn -> "#{__MODULE__} HTTP error: #{inspect(reason)}" end)
    state = %{state | buffer: ""}
    send(self(), :connect)
    {:noreply, [], state}
  end

  def handle_info(%HTTPoison.AsyncEnd{id: id}, %{id: id} = state) do
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

  if Application.get_env(:commuter_rail_boarding, :log_chunks) do
    def log_chunk(c) do
      _ =
        Logger.debug(fn ->
          "chunk: #{inspect(c, limit: :infinity, printable_limit: :infinity)}"
        end)

      :ok
    end
  else
    defp log_chunk(_) do
      :ok
    end
  end
end
