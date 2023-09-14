defmodule Uploader.Consumer do
  @moduledoc """
  GenStage consumer which uploads a binary to the configured Uploader.
  """
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
    _ = upload_events(events)

    {:noreply, [], state}
  end

  defp upload_events(events) do
    new_bucket = Application.get_env(:shared, :new_bucket)

    for {filename, body} <- Map.new(events) do
      Uploader.upload(filename, body)
      Uploader.upload(filename, body, new_bucket, [])
    end
  end
end
