defmodule DeparturesCSV.ProducerConsumer do
  @moduledoc """
  GenStage ProducerConsumer which turns a list of BoardingStatus structs into the legacy Departures.csv
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
    binary = events
    |> List.last
    |> DeparturesCSV.to_binary
    {:noreply, [{"Departures.csv", binary}], state}
  end
end
