defmodule TrainLoc.IntegrationTest do
  @moduledoc """
  This module contains the core logic for running integration test scenarios.

  To add a new integration test, create a new module that provides the function
  `TestModule.test_messages/0`. Write a new test in
  TrainLoc.IntegrationTest that passes the new module to
  `TrainLoc.IntegrationTest.run_test/1`.
  """
  use ExUnit.Case
  require Logger
  alias TrainLoc.S3.InMemory

  setup do
    Application.ensure_all_started(:train_loc)

    on_exit(fn ->
      TrainLoc.Manager.reset()
    end)
  end

  def run_test(test_module) do
    send_data(test_module.test_messages)

    assert map_size(InMemory.list_objects()) == 1
  end

  @spec send_data([[String.t()]]) :: any
  defp send_data(test_data) do
    for msg_batch <- test_data do
      {:ok, producer} =
        msg_batch
        |> Enum.join()
        |> String.split("\n\n")
        |> Enum.map(&ServerSentEventStage.Event.from_string/1)
        |> GenStage.from_enumerable()

      GenStage.sync_subscribe(TrainLoc.Manager, to: producer, cancel: :transient)

      :ok = await_down(producer)
      Logger.debug(fn -> "Batch sent." end)
    end

    # waits for the messages sent above to be processed
    TrainLoc.Manager.await()
  end

  defp await_down(pid) do
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, ^pid, expected}
      when expected in [:normal, :noproc] ->
        :ok
    after
      5_000 ->
        :timeout
    end
  end
end
