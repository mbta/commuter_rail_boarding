defmodule TrainLoc.Assignments.State do
    @moduledoc """
    GenServer for storing historical vehicle assignment data
    """

    use GenServer

    alias TrainLoc.Assignments.Assignments
    alias TrainLoc.Utilities.Time

    require Logger

    # Client Interface

    def start_link(opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def all_records(pid \\ __MODULE__) do
        GenServer.call(pid, :all_records)
    end

    def all_records_by_vehicle_block(pid \\ __MODULE__) do
        GenServer.call(pid, :all_by_vehicle_block)
    end

    def all_records_by_block_vehicle(pid \\ __MODULE__) do
        GenServer.call(pid, :all_by_block_vehicle)
    end

    def all_records_by_vehicle(pid \\ __MODULE__) do
        GenServer.call(pid, :all_by_vehicle)
    end

    def all_records_by_block(pid \\ __MODULE__) do
        GenServer.call(pid, :all_by_block)
    end

    def add_assignment(pid \\ __MODULE__, vehicle) do
        GenServer.call(pid, {:add, vehicle})
    end

    # Server Callbacks

    def init(_) do
        Logger.debug("Starting #{__MODULE__}...")
        Process.send_after(self(), :log_and_reset, millis_to_day_end())
        {:ok, MapSet.new()}
    end

    def handle_call(:all_records, _from, assigns) do
        {:reply, assigns, assigns}
    end

    def handle_call({:add, vehicle}, _from, assigns) do
        {:reply, :ok, Assignments.add(assigns, vehicle)}
    end

    def handle_call(:all_by_vehicle_block, _from, assigns) do
        {:reply, Assignments.group_by_vehicle_block(assigns), assigns}
    end

    def handle_call(:all_by_block_vehicle, _from, assigns) do
        {:reply, Assignments.group_by_block_vehicle(assigns), assigns}
    end

    def handle_call(:all_by_vehicle, _from, assigns) do
        {:reply, Assignments.group_by_vehicle(assigns), assigns}
    end

    def handle_call(:all_by_block, _from, assigns) do
        {:reply, Assignments.group_by_block(assigns), assigns}
    end

    def handle_call(_, _from, assigns) do
        {:reply, {:error, "Unknown callback."}, assigns}
    end

    def handle_info(:log_and_reset, assigns) do
        Process.send_after(self(), :log_and_reset, millis_to_day_end())
        Assignments.write_state(assigns)
        {:noreply, MapSet.new()}
    end

    def handle_info(_, assigns) do
        {:noreply, assigns}
    end

    def handle_cast(_, assigns) do
        {:noreply, assigns}
    end

    defp millis_to_day_end() do
        Time.local_now()
        |> Time.end_of_service_date()
        |> Time.time_until(Time.local_now())
    end
end
