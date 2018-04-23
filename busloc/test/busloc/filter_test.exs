defmodule Busloc.FilterTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Filter
  alias Busloc.Vehicle

  describe "filter/2" do
    test "removes vehicles with invalid timestamps" do
      now = DateTime.from_unix!(10_000)
      past = DateTime.from_unix!(5_000)
      future = DateTime.from_unix!(15_000)

      vehicles = [
        %Vehicle{timestamp: now},
        %Vehicle{timestamp: past},
        %Vehicle{timestamp: future}
      ]

      expected = Enum.take(vehicles, 1)
      actual = filter(vehicles, now)
      assert expected == actual
    end
  end
end
