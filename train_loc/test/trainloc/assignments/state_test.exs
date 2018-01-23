defmodule TrainLoc.Assignments.StateTest do
  
  use ExUnit.Case, async: true

  alias TrainLoc.Assignments.State

  setup do
    Application.ensure_all_started(:trainloc)
  end

  test "handles undefined call" do
    assert GenServer.call(State, :unknown_call) == {:error, "Unknown callback."}
  end

  test "handles undefined cast" do
    GenServer.cast(State, :unknown_cast)
  end

  test "handles undefined message" do
    send(State, :unknown_message)
  end
end
