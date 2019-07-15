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
      {:ok, state} = init(:assigned_logon_fetcher_test)
      assert handle_info(:timeout, state) == {:noreply, state}

      refute Busloc.State.get_all(:transitmaster_state) == []
    end
  end
end
