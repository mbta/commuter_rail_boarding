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
    {:producer_consumer, :state, init_opts(args)}
  end

  def handle_events(events, _from, state) do
    valid_event_data = for event <- events,
      {:ok, %{"data" => data}} when is_list(data) <- [Poison.decode(event.data)] do
        data
    end
    statuses = if valid_event_data == [] do
      []
    else
      [
        for {:ok, {:ok, status}} <- Task.async_stream(
              List.last(valid_event_data), &BoardingStatus.from_firebase/1) do
          status
        end
      ]
    end
    {:noreply, statuses, state}
  end
end
