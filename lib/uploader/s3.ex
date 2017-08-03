defmodule Uploader.S3 do
  @moduledoc """
  Uploader implementation which puts the file into an S3 bucket
  """
  @behaviour Uploader
  alias ExAws.S3
  require Logger

  @impl true
  def upload(binary) do
    request = S3.put_object(
      config(:bucket),
      "TripUpdates_enhanced.json",
      binary,
      acl: :public_read,
      content_type: "application/json")
    {time, result} = :timer.tc(fn -> config(:requestor).request!(request) end)
    log_result(time, result)
  end

  defp log_result(time, result) do
    _ = Logger.info(fn -> "#{__MODULE__} took #{time / 1000}ms: #{inspect result}" end)
    result
  end

  def config(key) do
    opts = Application.fetch_env!(:commuter_rail_boarding, Uploader.S3)
    do_config(Keyword.get(opts, key))
  end

  defp do_config({:system, envvar}) do
    System.get_env(envvar)
  end
  defp do_config(value) do
    value
  end
end
