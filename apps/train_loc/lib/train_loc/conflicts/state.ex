defmodule TrainLoc.Conflicts.State do
  @moduledoc """
  GenServer for tracking and querying the conflicting assignments in the
  system. Each conflict is represented by a `TrainLoc.Conflicts.Conflict`
  struct.
  """

  alias TrainLoc.Conflicts.Conflicts

  use GenServer

  require Logger

  # Client Interface

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def all_conflicts(pid \\ __MODULE__) do
    GenServer.call(pid, :all_conflicts)
  end

  def set_conflicts(pid \\ __MODULE__, conflicts)

  def set_conflicts(pid, conflicts) when is_list(conflicts) do
    conflicts = Conflicts.new(conflicts)
    set_conflicts(pid, conflicts)
  end

  def set_conflicts(pid, conflicts) do
    GenServer.call(pid, {:set, conflicts})
  end

  def reset(pid \\ __MODULE__) do
    GenServer.call(pid, :reset)
  end

  @doc """
  Awaits a reply.
  """
  def await(pid \\ __MODULE__) do
    GenServer.call(pid, :await)
  end

  # Server Callbacks

  def init(_) do
    Logger.debug(fn -> "Starting #{__MODULE__}..." end)
    {:ok, Conflicts.new()}
  end

  def handle_call(:all_conflicts, _from, known_conflicts) do
    {:reply, known_conflicts, known_conflicts}
  end

  def handle_call({:set, current_conflicts}, _from, known_conflicts) do
    {removed, added} = Conflicts.diff(known_conflicts, current_conflicts)
    {:reply, {removed, added}, current_conflicts}
  end

  def handle_call(:reset, _from, _known_conflicts) do
    {:reply, :ok, Conflicts.new()}
  end

  def handle_call(:await, _from, state) do
    {:reply, true, state}
  end

  # Catchalls

  def handle_call(_, _from, known_conflicts) do
    {:reply, {:error, "Unknown callback."}, known_conflicts}
  end

  def handle_cast(_, known_conflicts) do
    {:noreply, known_conflicts}
  end

  def handle_info(_, known_conflicts) do
    {:noreply, known_conflicts}
  end
end
