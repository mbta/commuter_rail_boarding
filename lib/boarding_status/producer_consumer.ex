defmodule BoardingStatus.ProducerConsumer do
  use GenStage

  def start_link(args) do
    opts = if name = Keyword.get(args, :name) do
      [name: name]
    else
      []
    end
    GenStage.start_link(__MODULE__, args, opts)
  end

  def init(args) do
    opts = if subscribe_to = Keyword.get(args, :subscribe_to) do
      [subscribe_to: subscribe_to]
    else
      []
    end
    {:producer_consumer, :state, opts}
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
