defmodule TrainLoc.IntegrationTest do
  @moduledoc """
  This module contains the core logic for running integration test scenarios.
  """
  use ExUnit.Case
  require Logger

  setup do
    Application.ensure_all_started(:trainloc)

    on_exit fn ->
      TrainLoc.Manager.reset()
      TrainLoc.Conflicts.State.reset()
      TrainLoc.Vehicles.State.reset()
    end
  end

  def run_test(test_module) do
    send_data(test_module.test_messages)

    assert TrainLoc.Vehicles.State.all_vehicles() == test_module.expected_vehicle_state
    assert TrainLoc.Conflicts.State.all_conflicts() == test_module.expected_conflict_state
  end

  @spec send_data([[String.t]]) :: any
  defp send_data(test_data) do
    for msg_batch <- test_data do
      Enum.each(msg_batch, fn msg ->
        send(TrainLoc.Input.APIFetcher, %HTTPoison.AsyncChunk{chunk: msg})
      end)
      Logger.debug(fn -> "Batch sent." end)
      :timer.sleep(5000)
    end
  end

  @tag :integration
  test "one minute of messages with 11 up-to-date vehicles and one conflict" do
    run_test(TrainLoc.IntegrationTest.Scenarios.OneMinute)
  end
end
