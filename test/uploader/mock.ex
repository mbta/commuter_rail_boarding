defmodule Uploader.Mock do
  @behaviour Uploader

  @impl true
  def upload(binary) do
    send self(), {:upload, binary}
    :ok
  end
end
