defmodule Busloc.LogHelperTest do
  use ExUnit.Case, async: true
  import Busloc.LogHelper

  defmodule(TestStruct, do: defstruct([:a]))
  alias __MODULE__.TestStruct

  doctest Busloc.LogHelper
end
