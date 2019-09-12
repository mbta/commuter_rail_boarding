defmodule Busloc.Fetcher.AssignedLogonFetcherTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Fetcher.AssignedLogonFetcher

  describe "handle_info(:timeout)" do
    setup do
      start_supervised!({Busloc.State, name: :transitmaster_state})
      :ok
    end

    @tag :capture_log
    test "updates vehicle state" do
      {:ok, state} = init([])
      assert handle_info(:timeout, state) == {:noreply, state}

      refute Busloc.State.get_all(:transitmaster_state) == []
    end
  end

  describe "init/1" do
    @tag :capture_log
    test "Sends a timeout on a failing db command" do
      {:ok, _state} = init(cmd: Busloc.Cmd.Failing, wait_for_db_connection: 1)
      assert_receive :timeout
    end
  end
end
