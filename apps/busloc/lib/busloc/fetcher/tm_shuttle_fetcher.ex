defmodule Busloc.Fetcher.TmShuttleFetcher do
  @moduledoc """
  Server to periodically query the TransitMaster DB for shuttle assignment data.
  """
  @frequency 30_000
  @wait_for_db_connection 300_000
  @default_name __MODULE__
  @cmd Busloc.Utilities.ConfigHelpers.config(TmShuttle, :cmd)

  use GenServer
  alias Busloc.TmShuttle
  alias Busloc.Cmd.Sqlcmd
  alias Busloc.MapDiff
  require Logger

  def start_link(opts) do
    table = Keyword.get(opts, :name, @default_name)
    GenServer.start_link(__MODULE__, table, opts)
  end

  def shuttle_assignment_by_vehicle(name \\ @default_name, vehicle_id) do
    case :ets.lookup(name, vehicle_id) do
      [{_, %TmShuttle{} = op}] -> {:ok, op}
      [] -> :error
    end
  rescue
    ArgumentError -> :error
  end

  @impl GenServer
  def init({table, options}) do
    :ets.new(table, [
      :set,
      :named_table,
      :protected,
      {:read_concurrency, true}
    ])

    cmd = Keyword.get(options, :cmd, @cmd)

    wait_for_db_connection =
      Keyword.get(options, :wait_for_db_connection, @wait_for_db_connection)

    state = %{table: table, cmd: cmd}

    if cmd.can_connect?() do
      {_, state} = handle_info(:timeout, state)
      {:ok, state}
    else
      Logger.warn("not starting #{__MODULE__}: cannot connect to TM DB")
      Process.send_after(self(), :timeout, wait_for_db_connection)
      {:ok, state}
    end
  end

  def init(table) do
    init({table, []})
  end

  def schedule_timeout! do
    Process.send_after(self(), :timeout, @frequency)
  end

  @impl GenServer
  def handle_info(:timeout, %{table: table} = state) do
    new_shuttles =
      state.cmd.shuttle_cmd()
      |> Sqlcmd.parse()
      |> Enum.flat_map(&TmShuttle.from_map/1)
      |> Map.new(fn %{vehicle_id: v} = x -> {v, x} end)

    {added, changed, deleted} = MapDiff.split(new_shuttles, MapDiff.get_all(table))

    :ets.insert(table, Map.to_list(new_shuttles))

    for shuttle <- Map.values(Map.merge(added, changed)) do
      Logger.info(fn -> TmShuttle.log_line(shuttle) end)
    end

    # delete any items which weren't part of the update
    delete_specs =
      for id <- Map.keys(deleted) do
        {{id, :_}, [], [true]}
      end

    _ = :ets.select_delete(table, delete_specs)
    schedule_timeout!()
    {:noreply, state}
  end

  def handle_info(message, state) do
    super(message, state)
  end
end
