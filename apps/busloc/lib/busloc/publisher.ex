defmodule Busloc.Publisher do
  use GenServer
  import Busloc.Utilities.ConfigHelpers
  require Logger

  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  def init(config) do
    schedule_timeout!()
    {:ok, config}
  end

  def handle_info(:timeout, config) do
    Logger.debug(fn ->
      "#{__MODULE__}: Fetching vehicle data to publish... encoder=#{config.encoder} uploader=#{
        config.uploader
      }"
    end)

    :ok = upload(config, DateTime.utc_now())
    schedule_timeout!()
    {:noreply, config}
  end

  def upload(config, now) do
    :ok =
      config.states
      |> Enum.flat_map(&Busloc.State.get_all/1)
      |> Busloc.Filter.filter(now)
      |> config.encoder.encode()
      |> config.uploader.upload(config)

    :ok
  end

  defp schedule_timeout! do
    Process.send_after(self(), :timeout, config(Publisher, :fetch_rate))
  end
end
