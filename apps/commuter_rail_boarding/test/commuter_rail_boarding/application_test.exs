defmodule CommuterRailBoarding.ApplicationTest do
  @moduledoc false
  use ExUnit.Case

  setup do
    start_children? =
      Application.get_env(:commuter_rail_boarding, :start_children?)

    Application.put_env(:commuter_rail_boarding, :start_children?, true)

    on_exit(fn ->
      Application.put_env(
        :commuter_rail_boarding,
        :start_children?,
        start_children?
      )
      Application.stop(:commuter_rail_boarding)
      Application.ensure_started(:commuter_rail_boarding)
    end)
  end

  test "starts the application" do
    Application.stop(:commuter_rail_boarding)
    assert Application.ensure_started(:commuter_rail_boarding) == :ok
  end
end
