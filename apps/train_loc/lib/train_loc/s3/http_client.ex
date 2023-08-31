defmodule TrainLoc.S3.HTTPClient do
  @moduledoc """
  S3 behaviour which actually uploads to S3.
  """
  @behaviour TrainLoc.S3

  @impl TrainLoc.S3
  def put_object(filename, body) do
    bucket = get_bucket()
    full_filename = Path.join("commuter_rail_boarding/train_loc", filename)
    opts = [acl: :public_read, content_type: "application/json"]

    bucket
    |> ExAws.S3.put_object(full_filename, body, opts)
    |> ExAws.request()
  end

  defp get_bucket do
    case Application.get_env(:train_loc, :s3_bucket) do
      {:system, varname} -> System.get_env(varname)
      _ -> nil
    end
  end
end
