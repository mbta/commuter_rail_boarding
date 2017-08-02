defmodule TripUpdates.ProducerConsumer do
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
    binary = events
    |> List.last
    |> TripUpdates.to_map
    |> Poison.encode!
    {:noreply, [binary], state}
  end
end
