defmodule TrainLoc.Input.APIFetcher do
  @moduledoc """
  Starts and maintains a connection to the Keolis event stream, which reports
  vehicle assignment information. The events are sent to `TrainLoc.Manager` for
  processing.
  """

  alias TrainLoc.Input.ServerSentEvent
  alias TrainLoc.Logging
  alias TrainLoc.Vehicles.Vehicle
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
  defstruct [
    url:        nil,
    url_getter: nil,
    send_to:    TrainLoc.Manager,
    buffer:     "",
    connected?: false,
  ]

  def init(url_getter) do
    state = %__MODULE__{
      url_getter: url_getter}
    if config(APIFetcher, :connect_at_startup?), do: send(self(), :connect)
    {:ok, state}
  end

  def handle_info({:configure, new_state}, state) when is_map(new_state) do
    {:noreply, Enum.reduce(Map.keys(new_state), state, &Map.put(&2, &1, new_state[&1]))}
  end
  def handle_info(:connect, state) do
    # 1 / 0
    state = compute_url(state)
    Logger.debug(fn -> "#{__MODULE__} requesting #{state.url}" end)
    headers = [
      {"Accept", "text/event-stream"}
    ]
    httpoison_opts = [
      recv_timeout: 60_000,
      stream_to: self(),
    ]
    {:ok, _} = HTTPoison.get(state.url, headers, httpoison_opts)
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
    IO.inspect(chunk, label: :raw_chunk)
    buffer = state.buffer <> chunk
    event_binaries = String.split(buffer, "\n\n")
    case Enum.split(event_binaries, -1) do
      {[], [buffer]} -> 
        state = %{state | buffer: buffer}
        {:noreply, state}
      {event_binaries, [buffer]} when length(event_binaries) > 0 ->
        {events, errors} = extract_events(event_binaries)
        handle_events_groups(state, events, errors)
        state = %{state | buffer: buffer}
        {:noreply, state}
    end
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

  def handle_call(:await, _from, state) do
    {:reply, true, state}
  end

  def handle_call(_msg, _from, state) do
    {:reply, {:error, "Unknown callback."}, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  #NO NO NO. This is not a url.
  defp compute_url(%{url: url} = state) when is_binary(url) do
    state
  end
  defp compute_url(%{url_getter: {m, f, a}} = state) do
    %{ state | url: apply(m, f, a) }
  end
  
  def log_empty_events_error(state) do
    reason = "No events parsed"
    log_keolis_error(state, reason)
  end

  def log_parsing_errors(state, []) do
    # this is a no_op clause
    nil
  end
  def log_parsing_errors(state, errored_events) do
    # IO.inspect(errors, label: "LOG_PARSING_ERRORS ERRORS")
    for sse <- errored_events do
      log_parsing_error(state, sse)
    end
  end

  # def log_parsing_error(state, error) when is_map(error) do
  #   error =
  #     error
  #     |> Map.put(:error_type, "Parsing Error")
  #   log_keolis_error(state, error)
  # end
  def log_parsing_error(state, %ServerSentEvent{} = sse) do
    error = %{
      error_type: "Parsing Error",
      errors: sse.errors,
    }
    log_keolis_error(state, error)
  end
  def log_parsing_error(state, error) when is_map(error) do
    error = 
      error
      |> Map.put(:error_type, "Parsing Error")
    log_keolis_error(state, error)
  end

  def send_events_for_processing(state, events) do
    Logger.info fn -> "#{__MODULE__} received #{length events} events" end
    for event <- events do
      Logger.debug(fn ->
        inspect(event, limit: :infinity, printable_limit: :infinity)
      end)
    end
    send(state.send_to, {:events, events})
  end

  def log_keolis_error(state, fields) when is_map(fields) do
    fields
    |> Map.put(:title, "Keolis API Failure")
    |> Map.put(:url, state.url)
    |> Logging.error
  end
  def log_keolis_error(state, reason) when is_binary(reason) do
    log_keolis_error(state, %{error_type: reason})
  end

  defp vehicles_from_data(%{"data" => %{"results" => results}} ) do
    Vehicle.from_json_map(results)
  end
  defp vehicles_from_data(%{"data" => data}) do
    Vehicle.from_json_object(data)
  end

  @doc """
    if we have an empty map:
      log as error
    if we have both errors and oks we want to:
        log the errors
        pass the oks for procvessing
    if we have no oks and we have errors:
      we want to log the errors
    
    if we have no errors and only oks
      we want to pass the oks for processing
    
  """
  def handle_events_groups(state, [], []) do
    log_empty_events_error(state)
  end
  # def handle_events_groups(state, [], errors) do
  #   log_parsing_errors(state, errors)
  # end
  # def handle_events_groups(state, events, []) do
  #   send_events_for_processing(state, events)
  # end
  def handle_events_groups(state, events, errors) do
    log_parsing_errors(state, errors)
    send_events_for_processing(state, events)
  end

  def extract_events(event_binaries) when is_list(event_binaries) do
    Enum.reduce(event_binaries, {[], []}, fn binary, {events_acc, errors_acc} -> 
      case ServerSentEvent.from_string(binary) do
        %{errors: []} = sse ->
          {[ sse | events_acc ], errors_acc}
        %{errors: errors} = errored_sse when length(errors) > 0 ->
          {events_acc, [ errored_sse | errors_acc ]}
      end
    end)
  end

  def into_result_groups(items) when is_list(items) do
    get_status = fn {status, _} -> status end
    get_output = fn {_, output} -> output end
    groups = Enum.group_by(items, get_status, get_output)
    oks = Map.get(groups, :ok, [])
    errors = Map.get(groups, :error, [])
    {oks, errors}
  end

end
