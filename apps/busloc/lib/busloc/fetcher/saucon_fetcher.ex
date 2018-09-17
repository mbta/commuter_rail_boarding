defmodule Busloc.Fetcher.SauconFetcher do
  @moduledoc """
  Fetch vehicle data from the Saucon API.
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
    Logger.warn("not starting SauconFetcher: no URL configured")
    :ignore
  end

  def handle_info(:timeout, %{url: url} = state) do
    vehicles =
      url
      |> HTTPoison.get!([], hackney: [pool: :default])
      |> Map.get(:body)
      |> Jason.decode!()
      |> Map.get("predictedRoute")
      |> Enum.flat_map(&Vehicle.from_saucon_json/1)
      |> Enum.map(&log_vehicle(&1, DateTime.utc_now()))

    Busloc.State.set(:saucon_state, vehicles)

    Process.send_after(self(), :timeout, config(SauconFetcher, :fetch_rate))
    {:noreply, state}
  end

  defp log_vehicle(vehicle, now) do
    Logger.info(fn ->
      Busloc.Vehicle.log_line(vehicle, now)
    end)

    vehicle
  end
end
