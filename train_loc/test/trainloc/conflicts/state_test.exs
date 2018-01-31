defmodule TrainLoc.Conflicts.StateTest do
  use ExUnit.Case, async: true
  alias TrainLoc.Conflicts.Conflict

  setup do
    Application.ensure_all_started(:trainloc)
  end

  test "handles undefined call" do
    assert GenServer.call(TrainLoc.Conflicts.State, :invalid_callback) == {:error, "Unknown callback."}
  end

  test "handles undefined cast" do
    GenServer.cast(TrainLoc.Conflicts.State, :unknown_cast)
  end

  test "handles undefined message" do
    send(TrainLoc.Conflicts.State, :unknown_message)
  end

  test "updates state of known conflicts and returns a diff" do
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

    assert {[], pre_existing} == TrainLoc.Conflicts.State.set_conflicts(pre_existing)
    assert {[conflict1], [conflict3]} == TrainLoc.Conflicts.State.set_conflicts(current)
    assert current == TrainLoc.Conflicts.State.all_conflicts()
  end
end
