defmodule Busloc.Tsp.Message do
  use GenServer, restart: :temporary
  require Logger

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def init(socket) do
    state = %{socket: socket, buffer: ""}
    {:ok, state}
  end

  def handle_info({:tcp, _port, data}, state) do
    :inet.setopts(state.socket, active: :once)

    Logger.debug(fn -> "Received TSP data: #{inspect(data)}" end)

    {urls, state} = data_to_urls(data, state)

    Logger.debug(fn -> "TSP state: #{inspect(state)}" end)

    for url <- urls do
      get_result = HTTPoison.get!(url)
      Logger.debug(fn -> "TSP post results: #{inspect(get_result)}" end)
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state) do
    Logger.warn("Busloc.Tsp.Message tcp_closed for socket #{inspect(state.socket)}")
    {:stop, :normal, state}
  end

  def handle_info(msg, state) do
    Logger.info("Busloc.Tsp.Message unknown message: #{inspect(msg)}")
    {:noreply, state}
  end

  def data_to_urls(data, state) do
    state = %{state | buffer: state.buffer <> data}

    case state.buffer do
      # 6-digit integer byte count
      <<"TMTSPDATAHEADER", length::binary-size(6), data::binary>> ->
        length = String.to_integer(length)

        if byte_size(data) < length do
          {[], state}
        else
          <<data::binary-size(length), buffer::binary>> = data
          state = %{state | buffer: buffer}
          url = xml_to_url(data)
          {urls, state} = data_to_urls("", state)
          {url ++ urls, state}
        end

      _ ->
        # Wait for more data
        {[], state}
    end
  end

  def xml_to_url(data) do
    {:ok, tsp} =
      data
      |> Busloc.XmlParser.parse_tsp_xml()
      |> Busloc.Tsp.from_tsp_map()

    case Busloc.Tsp.Sender.tsp_to_http(tsp) do
      "" ->
        []

      url ->
        [url]
    end
  end
end
