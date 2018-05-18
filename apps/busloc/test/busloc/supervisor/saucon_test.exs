defmodule Busloc.Supervisor.SauconTest do
  @moduledoc false
  use ExUnit.Case
  import Busloc.Supervisor.Saucon

  @tag :capture_log
  describe "start_link/0" do
    test "starts two childen" do
      {:ok, pid} = start_link()
      assert Supervisor.count_children(pid).specs == 2
    end
  end
end
