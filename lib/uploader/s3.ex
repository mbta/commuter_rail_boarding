defmodule Uploader.S3 do
  @behaviour Uploader
  alias ExAws.S3

  def upload(binary) do
    request = S3.put_object(
      config(:bucket),
      "TripUpdates_enhanced.json",
      binary)
    config(:requestor).request!(request)
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
