defmodule BoardingStatus.ProducerConsumer do
  @moduledoc """
  GenStage ProducerConsumer which takes a ServerSentEvent and parses it into a list of BoardingStatus structs.
  """
  use GenStage
  import StageHelpers

  # 5 minutes in milliseconds
  @default_timeout 5 * 60 * 1000
  defstruct [:producers, :timeout_ref, timeout_after: @default_timeout]

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, start_link_opts(args))
  end

  def init(args) do
    state = %__MODULE__{}
    producers = Keyword.fetch!(args, :subscribe_to)
    timeout_after = Keyword.get(args, :timeout_after, state.timeout_after)

    state =
      schedule_timeout(%{
        state
        | producers: producers,
          timeout_after: timeout_after
      })

    {:producer_consumer, state, init_opts(args)}
  end

  def handle_events(events, _from, state) do
    state = schedule_timeout(state)
    maybe_refresh!(events, state)

    valid_event_data =
      for %{event: "put"} = event <- events,
          {:ok, data} <- [Jason.decode(event.data, strings: :copy)],
          data <- valid_data(data) do
        data
      end

    statuses =
      if valid_event_data == [] do
        []
      else
        [
          for {:ok, {:ok, status}} <-
                Task.async_stream(
                  List.last(valid_event_data),
                  &BoardingStatus.from_firebase/1
                ) do
            status
          end
        ]
      end

    {:noreply, statuses, state}
  end

  def handle_info(
        :timeout,
        state,
        refresh_fn \\ &ServerSentEventStage.refresh/1
      ) do
    state = schedule_timeout(state)
    Enum.each(state.producers, refresh_fn)
    {:noreply, [], state}
  end

  defp valid_data(%{"data" => list}) when is_list(list) do
    [list]
  end

  defp valid_data(%{"data" => %{"results" => list}}) when is_list(list) do
    [list]
  end

  defp valid_data(_) do
    []
  end

  def maybe_refresh!(
        events,
        %{producers: producers},
        refresh_fn \\ &ServerSentEventStage.refresh/1
      ) do
    if should_refresh?(events) do
      Enum.each(producers, refresh_fn)
    end
  end

  defp should_refresh?(events) do
    Enum.any?(events, &(&1.event == "auth_revoked"))
  end

  defp schedule_timeout(state) do
    if state.timeout_ref do
      Process.cancel_timer(state.timeout_ref)
    end

    ref = Process.send_after(self(), :timeout, state.timeout_after)
    %{state | timeout_ref: ref}
  end
end
