defmodule Busloc.Publisher do
  use GenServer
  import Busloc.Utilities.ConfigHelpers
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    state_modules = Keyword.get(opts, :states, [Busloc.State])
    send(self(), :timeout)
    {:ok, state_modules}
  end

  def handle_info(:timeout, state_modules) do
    Logger.debug(fn -> "#{__MODULE__}: Fetching vehicle data to publish..." end)
    :ok = upload(state_modules, DateTime.utc_now())
    Process.send_after(self(), :timeout, config(Publisher, :fetch_rate))
    {:noreply, state_modules}
  end

  def upload(state_modules, now) do
    state_modules
    |> Enum.flat_map(&Busloc.State.get_all/1)
    |> Busloc.Filter.filter(now)
    |> Busloc.NextbusOutput.to_nextbus_xml()
    |> Busloc.Uploader.upload()

    :ok
  end
end
