defmodule Busloc.Supervisor.TransitmasterTest do
  @moduledoc false
  use ExUnit.Case
  import Busloc.Supervisor.Transitmaster

  @tag :capture_log
  describe "start_link/0" do
    test "starts six childen" do
      {:ok, pid} = start_link()
      assert Supervisor.count_children(pid).specs == 6
    end
  end
end
