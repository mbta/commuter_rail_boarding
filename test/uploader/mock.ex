defmodule Uploader.Mock do
  @behaviour Uploader

  @impl true
  def upload(filename, binary) do
    send(self(), {:upload, filename, binary})
    :ok
  end
end
