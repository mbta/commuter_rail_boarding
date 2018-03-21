defmodule TrainLoc.Conflicts.Conflicts do
  @moduledoc """
  Functions for working with collections of conflicts.
  """

  alias TrainLoc.Conflicts.Conflict

  @type conflicts_acc :: MapSet.t(Conflict.t())

  @spec new([Conflict.t()]) :: conflicts_acc
  def new(items \\ []) do
    MapSet.new(items)
  end

  @spec add(conflicts_acc, Conflict.t()) :: conflicts_acc
  def add(conflicts, %Conflict{} = to_add) do
    MapSet.put(conflicts, to_add)
  end

  @doc """
  Accepts a list of pre-existing conflicts and a list of what we've determined
  to be the current conflicts.

  Returns a tuple with removed conflicts and new conflicts.

  1. `removed_conflicts`: conflicts we no longer care about
  2. `new_conflicts`: conflicts TrainLoc has detected for the first time
  """
  @spec diff(conflicts_acc, conflicts_acc) :: {conflicts_acc, conflicts_acc}
  def diff(pre_existing_conflicts, current_conflicts) do
    new_conflicts = filter_only_unknown(pre_existing_conflicts, current_conflicts)
    removed_conflicts = filter_only_removed(pre_existing_conflicts, current_conflicts)
    {removed_conflicts, new_conflicts}
  end

  @spec remove(conflicts_acc, Conflict.t()) :: conflicts_acc
  def remove(conflicts, to_remove) do
    MapSet.delete(conflicts, to_remove)
  end

  @spec remove_many(conflicts_acc, conflicts_acc | [Conflict.t()]) :: conflicts_acc
  def remove_many(conflicts, to_remove) when is_list(to_remove) do
    remove_many(conflicts, new(to_remove))
  end

  def remove_many(conflicts, to_remove) do
    MapSet.difference(conflicts, to_remove)
  end

  @spec filter_by(conflicts_acc, Conflict.field(), any) :: conflicts_acc
  def filter_by(conflicts, field, value) do
    conflicts
    |> Enum.filter(fn conflict -> Map.get(conflict, field) == value end)
    |> Enum.into(new())
  end

  @spec filter_only_unknown(conflicts_acc, conflicts_acc) :: conflicts_acc
  def filter_only_unknown(old_conflicts, new_conflicts) do
    MapSet.difference(new_conflicts, old_conflicts)
  end

  @spec filter_only_removed(conflicts_acc, conflicts_acc) :: conflicts_acc
  def filter_only_removed(old_conflicts, new_conflicts) do
    MapSet.difference(old_conflicts, new_conflicts)
  end

  @spec contains_conflict?(conflicts_acc, Conflict.t()) :: boolean
  def contains_conflict?(conflicts, conflict) do
    conflict in conflicts
  end

  @spec size(conflicts_acc) :: non_neg_integer
  def size(conflicts) do
    MapSet.size(conflicts)
  end
end
