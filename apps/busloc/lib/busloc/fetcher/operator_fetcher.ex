defmodule Busloc.Fetcher.OperatorFetcher do
  @moduledoc """
  Server to periodically query the TransitMaster DB for operator data.
  """
  @frequency 30_000
  @default_name __MODULE__
  @cmd Busloc.Utilities.ConfigHelpers.config(Operator, :cmd)

  use GenServer
  alias Busloc.Operator
  alias Busloc.Cmd.Sqlcmd
  alias Busloc.MapDiff
  require Logger

  def start_link(opts) do
    table = Keyword.get(opts, :name, @default_name)
    GenServer.start_link(__MODULE__, table, opts)
  end

  def get_table(name \\ @default_name), do: name

  def operator_by_vehicle_block(name \\ @default_name, vehicle_id, block_id) do
    case :ets.lookup(name, {vehicle_id, block_id}) do
      [{_, %Operator{} = op}] -> {:ok, op}
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
    new_operators =
      @cmd.operator_cmd()
      |> Sqlcmd.parse()
      |> Enum.flat_map(&Operator.from_map/1)
      |> Map.new(fn %{vehicle_id: v, block: b} = x -> {{v, b}, x} end)

    {added, changed, deleted} = MapDiff.split(new_operators, MapDiff.get_all(table))

    :ets.insert(table, Map.to_list(new_operators))

    for operator <- Map.values(Map.merge(added, changed)) do
      Logger.info(fn -> Operator.log_line(operator) end)
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
