defmodule Busloc.Fetcher.TmFetcher do
  use GenServer

  import Busloc.Utilities.ConfigHelpers
  require Logger

  alias Busloc.XmlParser

  # Client Interface

  def start_link(opts) do
    url = Keyword.fetch!(opts, :url)
    GenServer.start_link(__MODULE__, url, opts)
  end

  # Server Callbacks

  def init(url) when is_binary(url) do
    state = %{url: url}
    send(self(), :timeout)
    {:ok, state}
  end

  def init(nil) do
    Logger.warn("not starting TmFetcher: no URL configured")
    :ignore
  end

  def handle_info(:timeout, %{url: url} = state) do
    with {:ok, body} <- get_xml(url),
         {:ok, vehicles} <- XmlParser.parse_transitmaster_xml(body),
         now = DateTime.utc_now() do
      vehicles
      |> Enum.flat_map(&from_transitmaster_map/1)
      |> Enum.map(&log_vehicle(&1, now))
      |> log_if_all_stale()
      |> (&Busloc.State.set(:transitmaster_state, &1)).()
    else
      error ->
        Logger.warn(fn ->
          "#{__MODULE__} error fetching #{inspect(url)} error=#{inspect(error)}"
        end)
    end

    send_timeout()
    {:noreply, state}
  end

  # Helper Functions

  @spec get_xml(String.t()) :: {:ok, String.t()} | {:error, any}
  def get_xml(url) do
    headers = [
      {"Accept", "text/xml"}
    ]

    with {:ok, xml_response} <- HTTPoison.get(url, headers) do
      {:ok, xml_response.body}
    end
  end

  def log_if_all_stale(vehicles) do
    max_time = vehicles |> Enum.map(&Timex.to_unix(&1.timestamp)) |> Enum.max()
    current_time = System.system_time(:seconds)

    if current_time - max_time > config(TmFetcher, :stale_seconds) do
      Logger.warn(fn -> "#{__MODULE__}: Transitmaster data is stale." end)
    end

    vehicles
  end

  defp send_timeout() do
    Process.send_after(self(), :timeout, config(TmFetcher, :fetch_rate))
  end

  defp from_transitmaster_map(map) do
    case Busloc.Vehicle.from_transitmaster_map(map) do
      {:ok, vehicle} ->
        [vehicle]

      error ->
        Logger.warn(fn ->
          "#{__MODULE__} unable to parse #{inspect(map)}: #{inspect(error)}"
        end)

        []
    end
  end

  defp log_vehicle(vehicle, now) do
    Logger.info(fn ->
      Busloc.Vehicle.log_line(vehicle, now)
    end)

    vehicle
  end
end