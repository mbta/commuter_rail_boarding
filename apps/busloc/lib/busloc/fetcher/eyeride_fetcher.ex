defmodule Busloc.Fetcher.EyerideFetcher do
  @moduledoc """
  Fetch vehicle data from the Eyeride API.

  We use two API calls:
  - /auth/login/ to get a token
  - /api/statistic/countbyday to get the list of vehicles
  """
  import Busloc.Utilities.ConfigHelpers
  use GenServer
  require Logger
  alias Busloc.Vehicle

  defstruct ~w(host headers)a

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    case Keyword.fetch(opts, :host) do
      {:ok, host} when is_binary(host) ->
        state = %__MODULE__{
          host: host,
          headers: headers(opts)
        }

        send(self(), :timeout)
        {:ok, state}

      _ ->
        Logger.warn("not starting Eyeride: no host configured")
        :ignore
    end
  end

  def handle_info(:timeout, state) do
    state
    |> url()
    |> HTTPoison.get!(state.headers)
    |> Map.get(:body)
    |> Poison.decode!()
    |> Enum.map(&Vehicle.from_eyeride_json/1)
    |> Enum.map(&log_vehicle(&1, DateTime.utc_now()))
    |> Enum.each(&Busloc.State.update/1)

    Process.send_after(self(), :timeout, config(EyerideFetcher, :fetch_rate))
    {:noreply, state}
  end

  defp log_vehicle(vehicle, now) do
    Logger.info(fn ->
      Busloc.Vehicle.log_line(vehicle, now)
    end)

    vehicle
  end

  def url(%{host: host}) do
    "http://#{host}/api/statistic/countbyday/"
  end

  def headers(opts) do
    email = Keyword.fetch!(opts, :email)
    password = Keyword.fetch!(opts, :password)
    host = Keyword.fetch!(opts, :host)
    body = Plug.Conn.Query.encode(email: email, password: password)

    token =
      "http://#{host}/auth/login/"
      |> HTTPoison.post!(body, [{"content-type", "application/x-www-form-urlencoded"}])
      |> Map.get(:body)
      |> Poison.decode!()
      |> Map.get("auth_token")

    [{"authorization", "Token #{token}"}]
  end
end
