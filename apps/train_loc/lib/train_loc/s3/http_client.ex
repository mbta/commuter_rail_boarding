defmodule TrainLoc.S3.HTTPClient do
  @moduledoc """
  S3 behaviour which actually uploads to S3.
  """
  @behaviour TrainLoc.S3

  @impl TrainLoc.S3
  def put_object(filename, body, bucket \\ get_bucket(), opts \\ [acl: :public_read]) do
    opts = [content_type: "application/json"] ++ opts

    bucket
    |> ExAws.S3.put_object(filename, body, opts)
    |> ExAws.request()
  end

  defp get_bucket do
    case Application.get_env(:train_loc, :s3_bucket) do
      {:system, varname} -> System.get_env(varname)
      _ -> nil
    end
  end
end
