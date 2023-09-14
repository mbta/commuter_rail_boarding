defmodule TrainLoc.S3 do
  @moduledoc """
  Defines a single callback:

  put_file/2 uploads file to S3
  """
  @type filename :: String.t()
  @type body :: String.t()
  @type bucket :: String.t()
  @type opts :: []

  @callback put_object(filename, body, bucket, opts) :: {:ok, term} | {:error, term}
end
