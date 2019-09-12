defmodule Busloc.Fetcher.AssignedLogonFetcher do
  @moduledoc """
  Server to periodically query the TransitMaster DB for dispatcher-assigned logon data.
  """
  import Busloc.Utilities.ConfigHelpers
  @wait_for_db_connection 300_000
  @cmd config(AssignedLogon, :cmd)

  use GenServer
  alias Busloc.AssignedLogon
  alias Busloc.Cmd.Sqlcmd
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @impl GenServer
  def init(options) do
    cmd = Keyword.get(options, :cmd, @cmd)

    wait_for_db_connection =
      Keyword.get(options, :wait_for_db_connection, @wait_for_db_connection)

    state = %{cmd: cmd}

    if cmd.can_connect?() do
      {_, state} = handle_info(:timeout, state)
      {:ok, state}
    else
      Logger.warn("not starting #{__MODULE__}: cannot connect to TM DB")
      Process.send_after(self(), :timeout, wait_for_db_connection)
      {:ok, state}
    end
  end

  def schedule_timeout! do
    Process.send_after(self(), :timeout, config(AssignedLogonFetcher, :fetch_rate))
  end

  @impl GenServer
  def handle_info(:timeout, state) do
    state.cmd.assigned_logon_cmd()
    |> Sqlcmd.parse()
    |> Enum.flat_map(&AssignedLogon.from_map/1)
    |> Enum.map(&log_assigned_logon/1)
    |> Enum.each(&Busloc.State.update_assigned_logon(:transitmaster_state, &1))

    schedule_timeout!()
    {:noreply, state}
  end

  def handle_info(message, state) do
    super(message, state)
  end

  defp log_assigned_logon(assigned_logon) do
    Logger.info(fn -> AssignedLogon.log_line(assigned_logon) end)
    assigned_logon
  end
end
