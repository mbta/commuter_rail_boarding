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
    process = fn _ ->
      now = DateTime.utc_now()

      url
      |> time(
        "fetch",
        &HTTPoison.post!(
          &1,
          body,
          [],
          hackney: [pool: :default],
          timeout: 30_000,
          recv_timeout: 30_000
        )
      )
      |> Map.get(:body)
      |> Jason.decode!()
      |> Map.get("vehicles")
      |> Stream.reject(&(Map.get(&1, "time", 0) == 0))
      |> Stream.map(&Vehicle.from_samsara_json/1)
      |> Stream.map(&log_vehicle(&1, now))
      |> Enum.each(&Busloc.State.update(:transitmaster_state, &1))
    end

    :ok = time(:ok, "process", process)

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
