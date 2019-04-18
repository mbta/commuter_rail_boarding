defmodule Busloc.MapDiffTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.MapDiff

  describe "split/3" do
    test "returns added/changed/deleted keys" do
      new = %{
        new: 1,
        existing: 2,
        changed: 3
      }

      existing = %{
        existing: 2,
        changed: 2,
        deleted: 4
      }

      {added, changed, deleted} = split(new, existing)
      assert added == %{new: 1}
      assert changed == %{changed: 3}
      assert deleted == %{deleted: 4}
    end
  end
end
