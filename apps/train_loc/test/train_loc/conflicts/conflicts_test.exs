defmodule TrainLoc.Conflicts.ConflictsTest do
  use ExUnit.Case, async: true
  alias TrainLoc.Conflicts.Conflict
  alias TrainLoc.Conflicts.Conflicts

  @conflict1 %Conflict{
    assign_type: :trip,
    assign_id: "123",
    vehicles: [1111, 2222],
    service_date: ~D[2017-09-02]
  }
  @conflict2 %Conflict{
    assign_type: :block,
    assign_id: "456",
    vehicles: [3333, 4444],
    service_date: ~D[2017-09-02]
  }
  @conflict3 %Conflict{
    assign_type: :block,
    assign_id: "789",
    vehicles: [5555, 6666],
    service_date: ~D[2017-09-01]
  }

  describe "new" do
    test "given no args (new/0) returns an emtpy MapSet" do
      result = Conflicts.new()
      assert %MapSet{} = result
      assert Conflicts.size(result) == 0
    end

    test "given a list (new/1) returns a MapSet with the items inside" do
      result = Conflicts.new([@conflict1, @conflict2])
      assert %MapSet{} = result
      assert Conflicts.size(result) == 2
      assert @conflict1 in result
      assert @conflict2 in result
    end
  end

  describe "size/1" do
    test "returns the size of a set of conflicts" do
      conflicts = Conflicts.new()
      assert Conflicts.size(conflicts) == 0
      added_one = Conflicts.add(conflicts, @conflict1)
      assert Conflicts.size(added_one) == 1
    end
  end

  describe "add/2" do
    test "adds items to the conflicts accumulator" do
      set = Conflicts.new()
      assert Conflicts.size(set) == 0
      set = Conflicts.add(set, @conflict1)
      assert Conflicts.size(set) == 1
      assert @conflict1 in set
    end

    test "does not add already existing items to the conflicts accumulator" do
      set = Conflicts.new()
      assert Conflicts.size(set) == 0
      set = Conflicts.add(set, @conflict1)
      assert Conflicts.size(set) == 1
      assert @conflict1 in set
      set = Conflicts.add(set, @conflict1)
      assert Conflicts.size(set) == 1
    end
  end

  describe "remove/2" do
    test "removes an existing conflict" do
      set = Conflicts.new([@conflict1])
      assert Conflicts.size(set) == 1
      set = Conflicts.remove(set, @conflict1)
      assert Conflicts.size(set) == 0
    end

    test "does not remove a conflict that is not an exact match" do
      set = Conflicts.new([@conflict1])
      assert Conflicts.size(set) == 1
      set = Conflicts.remove(set, @conflict2)
      assert Conflicts.size(set) == 1
      assert @conflict1 in set
    end
  end

  describe "filter_by/3" do
    test "removes conflicts that do not match the filter and keeps those that do match" do
      conflicts = Conflicts.new([@conflict1, @conflict2, @conflict3])
      assert Conflicts.size(conflicts) == 3
      trips_only = Conflicts.filter_by(conflicts, :assign_type, :trip)
      assert Conflicts.size(trips_only) == 1
      assert Conflicts.contains_conflict?(trips_only, @conflict1)
      refute Conflicts.contains_conflict?(trips_only, @conflict2)
      refute Conflicts.contains_conflict?(trips_only, @conflict3)
    end
  end

  describe "contains_conflict?/2" do
    test "true when conflict exists" do
      conflicts = Conflicts.new([@conflict1])
      assert Conflicts.contains_conflict?(conflicts, @conflict1)
    end

    test "false when conflict does not exist" do
      conflicts = Conflicts.new()
      refute Conflicts.contains_conflict?(conflicts, @conflict1)
    end
  end

  describe "diff/2" do
    test "should return the removed conflicts and the new conflicts" do
      pre_existing = Conflicts.new([@conflict1, @conflict2])
      current = Conflicts.new([@conflict2, @conflict3])
      {removed, new} = Conflicts.diff(pre_existing, current)
      assert removed == Conflicts.new([@conflict1])
      assert new == Conflicts.new([@conflict3])
    end

    test "should return the full set as new when initial set is empty" do
      pre_existing = Conflicts.new()
      current = Conflicts.new([@conflict2, @conflict3])
      {removed_conflicts, new_conflicts} = Conflicts.diff(pre_existing, current)
      # empty
      assert removed_conflicts == Conflicts.new()
      assert new_conflicts == Conflicts.new([@conflict2, @conflict3])
    end
  end

  describe "filter_only_unknown/2" do
    test "returns only the conflicts that are new conflicts" do
      current = Conflicts.new([@conflict1, @conflict2])
      others = Conflicts.new([@conflict1, @conflict2, @conflict3])
      new_conflicts = Conflicts.filter_only_unknown(current, others)
      assert new_conflicts == Conflicts.new([@conflict3])
    end
  end

  describe "remove_many/2" do
    test "removes the 2nd set of conflicts from the first set of conflicts" do
      first_set = Conflicts.new([@conflict1, @conflict2, @conflict3])
      second_set = Conflicts.new([@conflict1, @conflict2])
      kept = Conflicts.remove_many(first_set, second_set)
      assert kept == Conflicts.new([@conflict3])
    end
  end

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

    conflict3 = %Conflict{
      assign_type: :block,
      assign_id: "789",
      vehicles: [5555, 6666],
      service_date: ~D[2017-09-01]
    }

    conflicts =
      Conflicts.new()
      |> Conflicts.add(conflict1)
      |> Conflicts.add(conflict2)
      |> Conflicts.remove(conflict1)

    assert Conflicts.contains_conflict?(conflicts, conflict2)
    refute Conflicts.contains_conflict?(conflicts, conflict1)

    conflicts =
      conflicts
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

    conflicts = Conflicts.new([conflict1])
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

    conflict3 = %Conflict{
      assign_type: :block,
      assign_id: "789",
      vehicles: [5555, 6666],
      service_date: ~D[2017-09-01]
    }

    conflicts = Conflicts.new([conflict1, conflict2, conflict3])

    filtered_by_trip = Conflicts.filter_by(conflicts, :assign_type, :trip)

    assert Conflicts.contains_conflict?(filtered_by_trip, conflict1)
    refute Conflicts.contains_conflict?(filtered_by_trip, conflict2)
    refute Conflicts.contains_conflict?(filtered_by_trip, conflict3)

    filtered_by_date = Conflicts.filter_by(conflicts, :service_date, ~D[2017-09-02])

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

    conflict3 = %Conflict{
      assign_type: :block,
      assign_id: "789",
      vehicles: [5555, 6666],
      service_date: ~D[2017-09-01]
    }

    pre_existing = Conflicts.new([conflict1, conflict2])
    current = Conflicts.new([conflict2, conflict3])

    {removed, new} = Conflicts.diff(pre_existing, current)

    assert removed == Conflicts.new([conflict1])
    assert new == Conflicts.new([conflict3])
  end
end
