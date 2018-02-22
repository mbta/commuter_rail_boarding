defmodule Uploader do
  @moduledoc """
  Behaviour to upload a binary somewhere.

  What "somewhere" means is up to the implementation.
  """
  @callback upload(filename :: binary, body :: binary) :: :ok | {:error, term}

  def upload(filename, binary) do
    module = Application.fetch_env!(:commuter_rail_boarding, :uploader)
    module.upload(filename, binary)
  end
end
