defmodule Busloc.Fetcher.SamsaraFetcher do
  @moduledoc """

  """
  import Busloc.Utilities.ConfigHelpers
  use GenServer
  require Logger
  alias Busloc.Vehicle

  def start_link(opts) do
    url = Keyword.fetch!(opts, :url)
    GenServer.start_link(__MODULE__, url, opts)
  end

  def init(url) when is_binary(url) do
    state = %{url: url, body: config(SamsaraFetcher, :post_body)}
    send(self(), :timeout)
    {:ok, state}
  end

  def init(nil) do
    Logger.warn("not starting SamsaraFetcher: no URL configured")
    :ignore
  end

  def handle_info(:timeout, %{url: url, body: body} = state) do
    process = fn ->
      now = DateTime.utc_now()

      url
      |> time("fetch", &HTTPoison.post!(&1, body, [], hackney: [pool: :default]))
      |> time("map_get_body", &Map.get(&1, :body))
      |> time("jason", &Jason.decode!/1)
      |> time("map_get_vehicles", &Map.get(&1, "vehicles"))
      |> time("reject", fn vs -> Enum.reject(vs, &(Map.get(&1, "time", 0) == 0)) end)
      |> time("from_json", fn vs -> Enum.map(vs, &Vehicle.from_samsara_json/1) end)
      |> time("log", fn vs -> Enum.map(vs, &log_vehicle(&1, now)) end)
      |> time("update", fn vs -> Enum.each(vs, &Busloc.State.update(:transitmaster_state, &1)) end)
    end

    {time, _} = :timer.tc(process)

    Logger.debug(fn ->
      "#{__MODULE__} timing name=process ms=#{time / 1_000}"
    end)

    Process.send_after(self(), :timeout, config(SamsaraFetcher, :fetch_rate))
    {:noreply, state}
  end

  def time(arg, log_name, fun) do
    {time, ret} = :timer.tc(fun, [arg])

    Logger.debug(fn ->
      "#{__MODULE__} timing name=#{log_name} ms=#{time / 1_000}"
    end)

    ret
  end

  defp log_vehicle(vehicle, now) do
    Logger.info(fn ->
      Busloc.Vehicle.log_line(vehicle, now)
    end)

    vehicle
  end
end
