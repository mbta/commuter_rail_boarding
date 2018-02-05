defmodule TrainLoc.Conflicts.State do
  @moduledoc """
  GenServer for tracking and querying the conflicting assignments in the
  system. Each conflict is represented by a `TrainLoc.Conflicts.Conflict`
  struct.
  """

  alias TrainLoc.Conflicts.Conflicts

  use GenServer

  require Logger

  #Client Interface

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def all_conflicts(pid \\ __MODULE__) do
    GenServer.call(pid, :all_conflicts)
  end

  def add_conflict(pid \\ __MODULE__, conflict) do
    GenServer.call(pid, {:add, conflict})
  end

  def remove_conflict(pid \\ __MODULE__, conflict) do
    GenServer.call(pid, {:remove, conflict})
  end

  def remove_conflicts(pid \\ __MODULE__, conflicts) do
    GenServer.call(pid, {:remove_many, conflicts})
  end

  def filter_by_field(pid \\ __MODULE__, field, value) do
    GenServer.call(pid, {:filter_by, field, value})
  end

  def set_conflicts(pid \\ __MODULE__, conflicts) do
    GenServer.call(pid, {:set, conflicts})
  end

  def reset(pid \\ __MODULE__) do
    GenServer.call(pid, :reset)
  end

  def empty_message_queue?(pid \\ __MODULE__) do
    GenServer.call(pid, :empty_message_queue?)
  end

  #Server Callbacks

  def init(_) do
    Logger.debug(fn -> "Starting #{__MODULE__}..." end)
    {:ok, Conflicts.new()}
  end

  def handle_call(:all_conflicts, _from, known_conflicts) do
    {:reply, known_conflicts, known_conflicts}
  end

  def handle_call({:add, conflict}, _from, known_conflicts) do
    {:reply, :ok, Conflicts.add(known_conflicts, conflict)}
  end

  def handle_call({:remove, conflict}, _from, known_conflicts) do
    {:reply, :ok, Conflicts.remove(known_conflicts, conflict)}
  end

  def handle_call({:remove_many, conflicts}, _from, known_conflicts) do
    {:reply, :ok, Conflicts.remove_many(known_conflicts, conflicts)}
  end

  def handle_call({:filter_by, field, value}, _from, known_conflicts) do
    {:reply, Conflicts.filter_by(known_conflicts, field, value), known_conflicts}
  end

  def handle_call({:set, current_conflicts}, _from, known_conflicts) do
    {removed, added} = Conflicts.diff(known_conflicts, current_conflicts)
    {:reply, {removed, added}, current_conflicts}
  end

  def handle_call(:reset, _from, _known_conflicts) do
    {:reply, :ok, Conflicts.new()}
  end

  def handle_call(:empty_message_queue?, _from, state) do
      {:reply, true, state}
  end

  #Catchalls

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
