defmodule Busloc.TmFetcher do
  use GenServer

  import Busloc.Utilities.ConfigHelpers

  alias Busloc.XmlParser

  # Client Interface

  def start_link(opts) do
    url = Keyword.fetch!(opts, :url)
    GenServer.start_link(__MODULE__, url, opts)
  end

  # Server Callbacks

  def init(url) do
    state = %{url: url}
    send_timeout()
    {:ok, state}
  end

  def handle_info(:timeout, %{url: url} = state) do
    _parsed_xml =
      url
      |> get_xml()
      |> XmlParser.parse_transitmaster_xml()
      |> Enum.map(&Busloc.Vehicle.from_transitmaster_map/1)

    send_timeout()
    {:noreply, state}
  end

  # Helper Functions

  def get_xml(url) do
    headers = [
      {"Accept", "text/xml"}
    ]

    {:ok, xml_response} = HTTPoison.get(url, headers)

    xml_response.body
  end

  defp send_timeout() do
    Process.send_after(self(), :timeout, config(TmFetcher, :fetch_rate))
  end
end
