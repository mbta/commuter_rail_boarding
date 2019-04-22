defmodule BoardingStatus.ProducerConsumer do
  @moduledoc """
  GenStage ProducerConsumer which takes a ServerSentEvent and parses it into a list of BoardingStatus structs.
  """
  use GenStage
  import StageHelpers

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, start_link_opts(args))
  end

  def init(args) do
    producers = Keyword.fetch!(args, :subscribe_to)
    {:producer_consumer, %{producers: producers}, init_opts(args)}
  end

  def handle_events(events, _from, state) do
    maybe_refresh!(events, state)

    valid_event_data =
      for %{event: "put"} = event <- events,
          {:ok, data} <- [Poison.decode(event.data)],
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
end
