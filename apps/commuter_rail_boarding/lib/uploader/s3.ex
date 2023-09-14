defmodule Uploader.S3 do
  @moduledoc """
  Uploader implementation which puts the file into an S3 bucket
  """
  @behaviour Uploader
  alias ExAws.S3
  require Logger
  import ConfigHelpers

  @impl true
  def upload(
        filename,
        binary,
        bucket \\ config(Uploader.S3, :bucket),
        opts \\ [acl: :public_read]
      ) do
    opts = [content_type: "application/json"] ++ opts

    request =
      S3.put_object(
        bucket,
        filename,
        binary,
        opts
      )

    {time, result} = :timer.tc(fn -> request!(request) end)
    log_result(time, result)
  end

  defp request!(request) do
    config(Uploader.S3, :requestor).request!(request)
  end

  defp log_result(time, result) do
    _ =
      Logger.info(fn ->
        "#{__MODULE__} took #{time / 1000}ms: #{inspect(result)}"
      end)

    result
  end
end
