defmodule TrainLoc.Vehicles.StateTest do
  use ExUnit.Case, async: true

  setup do
    Application.ensure_all_started(:trainloc)
  end

  test "handles undefined call" do
    assert GenServer.call(TrainLoc.Vehicles.State, :unknown_call) == {:error, "Unknown callback."}
  end

  test "handles undefined cast" do
    GenServer.cast(TrainLoc.Vehicles.State, :unknown_cast)
  end

  test "handles undefined message" do
    send(TrainLoc.Vehicles.State, :unknown_message)
  end
end
