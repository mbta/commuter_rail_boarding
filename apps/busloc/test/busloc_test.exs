defmodule BuslocTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc

  describe "children/0" do
    test "builds a child for each uploader" do
      assert length(children()) == 5
    end
  end
end
