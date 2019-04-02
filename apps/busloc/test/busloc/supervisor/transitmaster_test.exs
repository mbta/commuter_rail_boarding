defmodule Busloc.Supervisor.TransitmasterTest do
  @moduledoc false
  use ExUnit.Case
  import Busloc.Supervisor.Transitmaster

  @tag :capture_log
  describe "start_link/0" do
    test "starts four childen" do
      {:ok, pid} = start_link()
      assert Supervisor.count_children(pid).specs == 5
    end
  end
end
