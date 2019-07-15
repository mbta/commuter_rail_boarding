defmodule Busloc.LogHelperTest do
  use ExUnit.Case, async: true
  import Busloc.LogHelper

  defmodule(TestStruct, do: defstruct([:a]))
  alias __MODULE__.TestStruct

  defmodule(TestVehicleStruct, do: defstruct([:assignment_timestamp, :operator_id, :vehicle_id]))
  alias __MODULE__.TestVehicleStruct

  doctest Busloc.LogHelper
end
