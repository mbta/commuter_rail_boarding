defmodule TrainLoc.S3 do
  @moduledoc """
  Defines a single callback:

  put_file/2 uploads file to S3
  """
  @type filename :: String.t
  @type body :: String.t

  @callback put_object(filename, body) :: {:ok, term} | {:error, term}
end
