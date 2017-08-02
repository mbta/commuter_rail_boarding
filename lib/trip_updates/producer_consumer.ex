defmodule TripUpdates.ProducerConsumer do
  use GenStage
  import StageHelpers

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, start_link_opts(args))
  end

  def init(args) do
    {:producer_consumer, :state, init_opts(args)}
  end

  def handle_events(events, _from, state) do
    binary = events
    |> List.last
    |> TripUpdates.to_map
    |> Poison.encode!
    {:noreply, [binary], state}
  end
end
