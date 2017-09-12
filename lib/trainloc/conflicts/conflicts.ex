defmodule TrainLoc.Conflicts.Conflicts do
    alias TrainLoc.Conflicts.Conflict

    @spec add([Conflict.t], Conflict.t) :: {:ok, [Conflict.t]}
    def add(conflicts, to_add) do
        if !contains_conflict(conflicts, to_add) do
            [to_add | conflicts]
        else
            conflicts
        end
    end

    @spec remove([Conflict.t], Conflict.t) :: {:ok, [Conflict.t]}
    def remove(conflicts, to_remove) do
        List.delete(conflicts, to_remove)
    end

    @spec remove_many([Conflict.t], [Conflict.t]) :: {:ok, [Conflict.t]}
    def remove_many(conflicts, to_remove) do
        to_remove |> Enum.reduce(conflicts, fn(x, acc) -> List.delete(acc, x) end)
    end

    @spec filter_by([Conflict.t], Conflict.field, any) :: [Conflict.t]
    def filter_by(conflicts, field, value) do
        conflicts |> Enum.filter(& Map.get(&1, field)==value)
    end

    @spec contains_conflict([Conflict.t], Conflict.t) :: boolean
    def contains_conflict(conflicts, conflict) do
        conflicts |> Enum.any?(& &1==conflict)
    end
end
