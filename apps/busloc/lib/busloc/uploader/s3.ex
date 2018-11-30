defmodule Busloc.Uploader.S3 do
  @moduledoc """
  Uploader which writes the file to an S3 bucket.
  """
  @behaviour Busloc.Uploader
  require Logger
  alias ExAws.S3

  @impl Busloc.Uploader
  def upload(binary, config) do
    request = s3_request(binary, config)
    %{status_code: 200} = ExAws.request!(request)

    Logger.debug(fn ->
      "#{__MODULE__} wrote bytes=#{byte_size(binary)} bucket=#{inspect(request.bucket)} path=#{
        inspect(request.path)
      }"
    end)

    :ok
  end

  def s3_request(binary, config) do
    path_name = config.bucket_prefix <> "/" <> config.filename

    S3.put_object(
      config.bucket_name,
      path_name,
      binary,
      acl: :public_read,
      content_type: content_type(config.filename)
    )
  end

  defp content_type(filename) do
    do_content_type(Path.extname(filename))
  end

  defp do_content_type(".json"), do: "application/json"
  defp do_content_type(".xml"), do: "text/xml"
  defp do_content_type(".pb"), do: "application/x-protobuf"
  defp do_content_type(_), do: "application/octet-stream"
end
