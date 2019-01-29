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
    end)
  end

  test "starts the application" do
    Application.stop(:commuter_rail_boarding)
    assert {:ok, _} = Application.ensure_all_started(:commuter_rail_boarding)
    Application.stop(:commuter_rail_boarding)
  end
end
