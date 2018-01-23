defmodule TrainLoc.Conflicts.StateTest do
  use ExUnit.Case, async: true

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
end
