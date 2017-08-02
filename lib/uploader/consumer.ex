defmodule Uploader.Consumer do
  use GenStage

  def start_link(args) do
    GenStage.start_link(__MODULE__, args)
  end

  # Server callbacks
  def init(args) do
    opts = if subscribe_to = Keyword.get(args, :subscribe_to) do
      [subscribe_to: subscribe_to]
    else
      []
    end
    {:consumer, :state, opts}
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
