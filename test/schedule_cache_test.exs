defmodule ScheduleCacheTest do
  @moduledoc false
  use ExUnit.Case, async: true
  doctest ScheduleCache
  import ScheduleCache

  describe "handle_info(:timeout)" do
    test "clears the table" do
      assert {:noreply, :state} = handle_info(:timeout, :state)
      assert :ets.info(ScheduleCache.Table, :size) == 0
    end
  end
end
