defmodule Busloc.TestUploader do
  @moduledoc false
  @behaviour Busloc.Uploader

  def upload(binary, config) do
    send(self(), {:upload, binary, config})
    :ok
  end
end
