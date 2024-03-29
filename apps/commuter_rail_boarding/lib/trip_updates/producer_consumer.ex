defmodule TripUpdates.ProducerConsumer do
  @moduledoc """
  GenStage ProducerConsumer which turns a list of BoardingStatus structs into an enhanced TripUpdates JSON file.
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
    binary =
      events
      |> List.last()
      |> TripUpdates.to_map()
      |> Jason.encode!()

    {:noreply, [{"TripUpdates_enhanced.json", binary}], state}
  end
end
