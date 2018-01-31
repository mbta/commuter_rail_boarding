defmodule TrainLoc.Conflicts.Conflicts do
  @moduledoc """
  Functions for working with collections of conflicts.
  """

  alias TrainLoc.Conflicts.Conflict

  @spec new() :: []
  def new() do
    []
  end

  @spec add([Conflict.t], Conflict.t) :: {:ok, [Conflict.t]}
  def add(conflicts, to_add) do
    if not contains_conflict?(conflicts, to_add) do
      [to_add | conflicts]
    else
      conflicts
    end
  end

  @doc """
  Accepts a list of pre-existing conflicts and a list of what we've determined
  to be the current conflicts.

  Returns a tuple with removed conflicts and new conflicts.

  1. `removed_conflicts`: conflicts we no longer care about
  2. `new_conflicts`: conflicts TrainLoc has detected for the first time
  """
  @spec diff([Conflict.t], [Conflict.t]) :: {[Conflict.t], [Conflict.t]}
  def diff(pre_existing_conflicts, current_conflicts) do
    new_conflicts = filter_only_unknown(pre_existing_conflicts, current_conflicts)
    removed_conflicts = filter_only_removed(pre_existing_conflicts, current_conflicts)
    {removed_conflicts, new_conflicts}
  end

  @spec remove([Conflict.t], Conflict.t) :: {:ok, [Conflict.t]}
  def remove(conflicts, to_remove) do
    List.delete(conflicts, to_remove)
  end

  @spec remove_many([Conflict.t], [Conflict.t]) :: [Conflict.t]
  def remove_many(conflicts, to_remove) do
    Enum.reduce(to_remove, conflicts, fn(x, acc) -> List.delete(acc, x) end)
  end

  @spec filter_by([Conflict.t], Conflict.field, any) :: [Conflict.t]
  def filter_by(conflicts, field, value) do
    Enum.filter(conflicts, & Map.get(&1, field)==value)
  end

  @spec filter_only_unknown([Conflict.t], [Conflict.t]) :: [Conflict.t]
  def filter_only_unknown(old_conflicts, new_conflicts) do
    new_conflicts -- old_conflicts
  end

  @spec filter_only_removed([Conflict.t], [Conflict.t]) :: [Conflict.t]
  def filter_only_removed(old_conflicts, new_conflicts) do
    old_conflicts -- new_conflicts
  end

  @spec contains_conflict?([Conflict.t], Conflict.t) :: boolean
  def contains_conflict?(conflicts, conflict) do
    conflict in conflicts
  end
end
