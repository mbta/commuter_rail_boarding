defmodule TrainLoc.Conflicts.ConflictsTest do
    use ExUnit.Case, async: true
    alias TrainLoc.Conflicts.Conflict
    alias TrainLoc.Conflicts.Conflicts

    test "adds and removes conflicts" do
        conflict1 = %Conflict{
            assign_type: :pattern,
            assign_id: "123",
            vehicles: ["1111", "2222"],
            service_date: ~D[2017-09-02]
        }
        conflict2 = %Conflict{
            assign_type: :workpiece,
            assign_id: "456",
            vehicles: ["3333", "4444"],
            service_date: ~D[2017-09-02]
        }
        conflict3 = %Conflict {
            assign_type: :workpiece,
            assign_id: "789",
            vehicles: ["5555", "6666"],
            service_date: ~D[2017-09-01]
        }
        conflicts = [] |> Conflicts.add(conflict1) |> Conflicts.add(conflict2) |> Conflicts.add(conflict3)
        assert conflicts == [conflict3, conflict2, conflict1]

        assert Conflicts.remove(conflicts, conflict3) == [conflict2, conflict1]
        assert Conflicts.remove_many(conflicts, [conflict1, conflict2]) == [conflict3]
    end

    test "checks whether conflict is in list" do
        conflict1 = %Conflict{
            assign_type: :pattern,
            assign_id: "123",
            vehicles: ["1111", "2222"],
            service_date: ~D[2017-09-02]
        }
        conflict2 = %Conflict{
            assign_type: :workpiece,
            assign_id: "456",
            vehicles: ["3333", "4444"],
            service_date: ~D[2017-09-02]
        }
        assert Conflicts.contains_conflict([conflict1], conflict1)
        assert !Conflicts.contains_conflict([conflict2], conflict1)
    end

    test "filters conflict list by field/value" do
        conflict1 = %Conflict{
            assign_type: :pattern,
            assign_id: "123",
            vehicles: ["1111", "2222"],
            service_date: ~D[2017-09-02]
        }
        conflict2 = %Conflict{
            assign_type: :workpiece,
            assign_id: "456",
            vehicles: ["3333", "4444"],
            service_date: ~D[2017-09-02]
        }
        conflict3 = %Conflict {
            assign_type: :workpiece,
            assign_id: "789",
            vehicles: ["5555", "6666"],
            service_date: ~D[2017-09-01]
        }

        conflicts = [conflict1, conflict2, conflict3]

        assert Conflicts.filter_by(conflicts, :assign_type, :pattern)==[conflict1]
        assert Conflicts.filter_by(conflicts, :service_date, ~D[2017-09-02])==[conflict1, conflict2]
    end
end
