defmodule Busloc.Tsp.Listener do
  @moduledoc """
  Supervised process that spends most of its time in a TCP accept
  loop. If the accept loop fails, its supervisor should restart it all.
  """

  use GenServer
  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    Logger.info("Initializing TSP Listener")

    case :gen_tcp.listen(port, [:binary, active: :once, reuseaddr: true]) do
      {:ok, lsock} ->
        Logger.info("Listening on port #{port}")
        GenServer.cast(self(), :accept)
        {:ok, %{lsock: lsock}}

      {:error, _} ->
        :ignore
    end
  end

  def handle_cast(:accept, %{lsock: lsock} = state) do
    case :gen_tcp.accept(lsock, 3_000) do
      {:ok, sock} ->
        Logger.info("Accepted socket: #{inspect(sock)}")

        {:ok, pid} = Busloc.Tsp.MessageSupervisor.start_child(sock)
        :ok = :gen_tcp.controlling_process(sock, pid)

        GenServer.cast(self(), :accept)
        {:noreply, state}

      {:error, :timeout} ->
        GenServer.cast(self(), :accept)
        {:noreply, state}

      {:error, err} ->
        Logger.error("Socket listener died: #{inspect(err)}")
        :ok = :gen_tcp.close(lsock)
        {:stop, :loop_accept_dead, %{}}
    end
  end
end
