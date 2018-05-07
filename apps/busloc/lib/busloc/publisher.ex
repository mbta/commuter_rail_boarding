defmodule Busloc.Publisher do
  use GenServer
  import Busloc.Utilities.ConfigHelpers
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_) do
    send(self(), :timeout)
    {:ok, :ignored}
  end

  def handle_info(:timeout, state) do
    Logger.debug(fn -> "#{__MODULE__}: Fetching vehicle data to publish..." end)
    :ok = upload(DateTime.utc_now())
    Process.send_after(self(), :timeout, config(Publisher, :fetch_rate))
    {:noreply, state}
  end

  def upload(now) do
    Busloc.State.get_all()
    |> Busloc.Filter.filter(now)
    |> Busloc.NextbusOutput.to_nextbus_xml()
    |> Busloc.Uploader.upload()

    :ok
  end
end
