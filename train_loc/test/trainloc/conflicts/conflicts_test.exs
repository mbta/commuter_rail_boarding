defmodule TrainLoc.Conflicts.ConflictsTest do

  use ExUnit.Case, async: true

  alias TrainLoc.Conflicts.Conflict
  alias TrainLoc.Conflicts.Conflicts

  test "adds and removes conflicts" do
    conflict1 = %Conflict{
      assign_type: :trip,
      assign_id: "123",
      vehicles: [1111, 2222],
      service_date: ~D[2017-09-02]
    }
    conflict2 = %Conflict{
      assign_type: :block,
      assign_id: "456",
      vehicles: [3333, 4444],
      service_date: ~D[2017-09-02]
    }
    conflict3 = %Conflict {
      assign_type: :block,
      assign_id: "789",
      vehicles: [5555, 6666],
      service_date: ~D[2017-09-01]
    }
    conflicts = Conflicts.new()
      |> Conflicts.add(conflict1)
      |> Conflicts.add(conflict2)
      |> Conflicts.remove(conflict1)

    assert Conflicts.contains_conflict?(conflicts, conflict2)
    refute Conflicts.contains_conflict?(conflicts, conflict1)

    conflicts = conflicts
      |> Conflicts.add(conflict3)
      |> Conflicts.remove_many([conflict2, conflict3])

    refute Conflicts.contains_conflict?(conflicts, conflict2)
    refute Conflicts.contains_conflict?(conflicts, conflict3)
  end

  test "checks whether conflict is in storage" do
    conflict1 = %Conflict{
      assign_type: :trip,
      assign_id: "123",
      vehicles: [1111, 2222],
      service_date: ~D[2017-09-02]
    }
    conflict2 = %Conflict{
      assign_type: :block,
      assign_id: "456",
      vehicles: [3333, 4444],
      service_date: ~D[2017-09-02]
    }

    conflicts = Conflicts.new()
      |> Conflicts.add(conflict1)

    assert Conflicts.contains_conflict?(conflicts, conflict1)
    refute Conflicts.contains_conflict?(conflicts, conflict2)
  end

  test "filters conflicts by field/value" do
    conflict1 = %Conflict{
      assign_type: :trip,
      assign_id: "123",
      vehicles: [1111, 2222],
      service_date: ~D[2017-09-02]
    }
    conflict2 = %Conflict{
      assign_type: :block,
      assign_id: "456",
      vehicles: [3333, 4444],
      service_date: ~D[2017-09-02]
    }
    conflict3 = %Conflict {
      assign_type: :block,
      assign_id: "789",
      vehicles: [5555, 6666],
      service_date: ~D[2017-09-01]
    }

    conflicts = Conflicts.new()
      |> Conflicts.add(conflict1)
      |> Conflicts.add(conflict2)
      |> Conflicts.add(conflict3)

    filtered_by_trip = Conflicts.filter_by(conflicts, :assign_type, :trip)

    assert Conflicts.contains_conflict?(filtered_by_trip, conflict1)
    refute Conflicts.contains_conflict?(filtered_by_trip, conflict2)
    refute Conflicts.contains_conflict?(filtered_by_trip, conflict3)

    filtered_by_date =  Conflicts.filter_by(conflicts, :service_date, ~D[2017-09-02])

    assert Conflicts.contains_conflict?(filtered_by_date, conflict1)
    assert Conflicts.contains_conflict?(filtered_by_date, conflict2)
    refute Conflicts.contains_conflict?(filtered_by_date, conflict3)
  end

  test "diffs the pre-existing and current conflicts" do

    conflict1 = %Conflict{
      assign_type: :trip,
      assign_id: "123",
      vehicles: [1111, 2222],
      service_date: ~D[2017-09-02]
    }
    conflict2 = %Conflict{
      assign_type: :block,
      assign_id: "456",
      vehicles: [3333, 4444],
      service_date: ~D[2017-09-02]
    }
    conflict3 = %Conflict {
      assign_type: :block,
      assign_id: "789",
      vehicles: [5555, 6666],
      service_date: ~D[2017-09-01]
    }

    pre_existing = [conflict1, conflict2]
    current = [conflict2, conflict3]

    {removed, new} = Conflicts.diff(pre_existing, current)
    assert removed == [conflict1]
    assert new == [conflict3]
  end
end
