defmodule Uploader do
  @moduledoc """
  Behaviour to upload a binary somewhere.

  What "somewhere" means is up to the implementation.
  """
  @callback upload(binary) :: :ok | {:error, term}

  def upload(binary) do
    module = Application.fetch_env!(:commuter_rail_boarding, :uploader)
    module.upload(binary)
  end
end
