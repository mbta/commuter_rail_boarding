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
    state = %{url: url}
    send(self(), :timeout)
    {:ok, state}
  end

  def init(nil) do
    Logger.warn("not starting SamsaraFetcher: no URL configured")
    :ignore
  end

  def handle_info(:timeout, %{url: url} = state) do
    process = fn ->
      now = DateTime.utc_now()

      url
      |> HTTPoison.post!(config(SamsaraFetcher, :post_body))
      |> Map.get(:body)
      |> Jason.decode!()
      |> Map.get("vehicles")
      |> Enum.reject(&(Map.get(&1, "time", 0) == 0))
      |> Enum.map(&Vehicle.from_samsara_json/1)
      |> Enum.map(&log_vehicle(&1, now))
      |> Enum.each(&Busloc.State.update(:transitmaster_state, &1))
    end

    {time, _} = :timer.tc(process)

    Logger.debug(fn ->
      "#{__MODULE__}.process took ms=#{time / 1_000}"
    end)

    Process.send_after(self(), :timeout, config(SamsaraFetcher, :fetch_rate))
    {:noreply, state}
  end

  defp log_vehicle(vehicle, now) do
    Logger.info(fn ->
      Busloc.Vehicle.log_line(vehicle, now)
    end)

    vehicle
  end
end
