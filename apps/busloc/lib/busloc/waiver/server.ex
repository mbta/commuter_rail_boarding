defmodule Busloc.Waiver.Server do
  @moduledoc """
  Server to periodically query the TransitMaster DB for waiver data.
  """
  @frequency 60_000
  @cmd Busloc.Utilities.ConfigHelpers.config(Waiver, :cmd)

  use GenServer
  alias Busloc.Waiver
  alias Busloc.Waiver.Parse
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init([]) do
    if @cmd.can_connect?() do
      state = %{updated_at: DateTime.utc_now()}
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
  def handle_info(:timeout, %{updated_at: updated_at} = state) do
    waivers = Parse.parse(@cmd.cmd())
    new_waivers = Enum.filter(waivers, &(DateTime.compare(&1.updated_at, updated_at) == :gt))

    state =
      if new_waivers == [] do
        state
      else
        for waiver <- new_waivers do
          Logger.info(fn -> Waiver.log_line(waiver) end)
        end

        new_updated_at = Enum.max_by(new_waivers, &DateTime.to_unix(&1.updated_at)).updated_at
        %{state | updated_at: new_updated_at}
      end

    schedule_timeout!()
    {:noreply, state}
  end

  def handle_info(message, state) do
    super(message, state)
  end
end
