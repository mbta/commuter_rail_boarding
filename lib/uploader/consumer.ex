defmodule Uploader.Consumer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :ok)
  end

  # Server callbacks
  def init(:ok) do
    {:consumer, :state}
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
