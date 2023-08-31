defmodule Uploader do
  @moduledoc """
  Behaviour to upload a binary somewhere.

  What "somewhere" means is up to the implementation.
  """
  import ConfigHelpers

  @callback upload(filename :: binary, body :: binary, bucket :: binary, opts :: []) ::
              :ok | {:error, term}

  def upload(
        filename,
        binary,
        bucket \\ config(Uploader.S3, :bucket),
        opts \\ [acl: :public_read]
      ) do
    module = Application.fetch_env!(:commuter_rail_boarding, :uploader)
    module.upload(filename, binary, bucket, opts)
  end
end
