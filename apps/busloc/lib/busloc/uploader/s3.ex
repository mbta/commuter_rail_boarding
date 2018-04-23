defmodule Busloc.Uploader.S3 do
  @moduledoc """
  Uploader which writes the file to an S3 bucket.
  """
  @behaviour Busloc.Uploader
  import Busloc.Utilities.ConfigHelpers
  require Logger
  alias ExAws.S3

  @impl Busloc.Uploader
  def upload(binary) do
    request = s3_request(binary)
    %{status_code: 200} = ExAws.request!(request)

    Logger.info(fn ->
      "#{__MODULE__} wrote bytes=#{byte_size(binary)} bucket=#{inspect(request.bucket)} path=#{
        inspect(request.path)
      }"
    end)

    :ok
  end

  def s3_request(binary) do
    bucket_name = config(Uploader.S3, :bucket_name)
    bucket_prefix = config(Uploader.S3, :bucket_prefix)
    path_name = bucket_prefix <> "/nextbus.xml"
    S3.put_object(bucket_name, path_name, binary, acl: :public_read, content_type: "text/xml")
  end
end
