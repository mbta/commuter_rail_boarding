defmodule Busloc.TestUploader do
  @moduledoc false
  @behaviour Busloc.Uploader

  def upload(binary) do
    send(self(), {:upload, binary})
    :ok
  end
end
