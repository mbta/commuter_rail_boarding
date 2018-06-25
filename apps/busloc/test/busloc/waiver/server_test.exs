defmodule Busloc.Waiver.ServerTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureLog

  import Busloc.Waiver.Server

  describe "start_link/1" do
    test "can start" do
      start_supervised!(Busloc.Waiver.Server)
    end
  end

  describe "handle_info(:timeout)" do
    setup do
      {:ok, state} = init([])
      state = %{state | updated_at: DateTime.from_unix!(0)}
      {:ok, state: state}
    end

    test "logs the waivers if they're newer than updated_at", %{state: state} do
      log =
        capture_log(fn ->
          _ = handle_info(:timeout, state)
        end)

      assert log =~ "Waiver - "
    end

    test "does not log the waivers if they're older than updated_at", %{state: state} do
      state = %{state | updated_at: DateTime.utc_now()}

      log =
        capture_log(fn ->
          _ = handle_info(:timeout, state)
        end)

      refute log =~ "Waiver - "
    end

    @tag :capture_log
    test "sets updated_at in the state", %{state: state} do
      {:noreply, new_state} = handle_info(:timeout, state)
      refute new_state.updated_at == state.updated_at
    end
  end

  describe "handle_info(other)" do
    test "logs a message" do
      log =
        capture_log(fn ->
          assert {:noreply, :state} = handle_info(:other, :state)
        end)

      assert log =~ ":other"
    end
  end
end
