defmodule Uploader.Consumer do
  use GenStage
  import StageHelpers

  def start_link(args) do
    GenStage.start_link(__MODULE__, args, start_link_opts(args))
  end

  # Server callbacks
  def init(args) do
    {:consumer, :state, init_opts(args)}
  end

  def handle_events(events, _from, state) do
    # Upload the last event.  Uploading any others would simply be overriden
    # by the previous ones.
    events
    |> List.last
    |> Uploader.upload

    {:noreply, [], state}
  end
end
