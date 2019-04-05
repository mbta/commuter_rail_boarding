defmodule Busloc.Fetcher.TmShuttleFetcher do
  @moduledoc """
  Server to periodically query the TransitMaster DB for shuttle assignment data.
  """
  @frequency 30_000
  @default_name __MODULE__
  @cmd Busloc.Utilities.ConfigHelpers.config(TmShuttle, :cmd)

  use GenServer
  alias Busloc.TmShuttle
  alias Busloc.Cmd.Sqlcmd
  require Logger

  def start_link(opts) do
    table = Keyword.get(opts, :name, @default_name)
    GenServer.start_link(__MODULE__, table, opts)
  end

  def get_table(name \\ @default_name), do: name

  def shuttle_assignment_by_vehicle(name \\ @default_name, vehicle_id) do
    case :ets.lookup(name, vehicle_id) do
      [{_, %TmShuttle{} = op}] -> {:ok, op}
      [] -> :error
    end
  rescue
    ArgumentError -> :error
  end

  @impl GenServer
  def init(table) do
    if @cmd.can_connect?() do
      :ets.new(table, [
        :set,
        :named_table,
        :protected,
        {:read_concurrency, true}
      ])

      state = %{table: table}
      {_, state} = handle_info(:timeout, state)
      {:ok, state}
    else
      Logger.warn("not starting #{__MODULE__}: cannot connect to TM DB")
      :ignore
    end
  end

  def schedule_timeout! do
    Process.send_after(self(), :timeout, @frequency)
  end

  @impl GenServer
  def handle_info(:timeout, %{table: table} = state) do
    new_shuttles =
      @cmd.shuttle_cmd()
      |> Sqlcmd.parse()
      |> Enum.flat_map(&TmShuttle.from_map/1)
      |> Map.new(fn %{vehicle_id: v} = x -> {v, x} end)

    {added, changed, deleted} = split(new_shuttles, get_all(table))

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

  defp get_all(table) do
    Map.new(:ets.tab2list(table))
  end

  @doc """
  Split the `new` map into three maps, relative to the `existing` map:

  - added keys
  - changed keys
  - deleted keys

  Keys which have the same value in `existing` are dropped.
  """
  def split(new, existing) do
    {a, added} = Map.split(new, Map.keys(existing))
    {c, deleted} = Map.split(existing, Map.keys(new))

    changed =
      for {key, value} = tuple <- a, Map.fetch!(c, key) != value, into: %{} do
        tuple
      end

    {added, changed, deleted}
  end
end
