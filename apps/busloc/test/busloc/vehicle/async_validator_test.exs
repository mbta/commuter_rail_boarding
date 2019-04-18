defmodule Busloc.Vehicle.AsyncValidatorTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  import Busloc.Vehicle.AsyncValidator
  import Busloc.Utilities.ConfigHelpers
  alias Busloc.Vehicle

  describe "validate_speed/2" do
    setup do
      start_supervised!(Busloc.Vehicle.AsyncValidator)
      %{ang_speed_threshold: config(AsyncValidator, :ang_speed_threshold)}
    end

    test "logs a message when vehicle speed exceeds threshold", state do
      vehicle_one = %Vehicle{
        vehicle_id: "1234",
        latitude: 42,
        longitude: -71,
        timestamp: 1
      }

      vehicle_two = %Vehicle{
        vehicle_id: "1234",
        latitude: 42.1,
        longitude: -71.1,
        timestamp: 2
      }

      fun = fn -> handle_cast({:validate_speed, vehicle_one, vehicle_two}, state) end

      expected_log = "Speed too high"

      assert capture_log(fun) =~ expected_log
    end

    test "doesn't log a message when speed is below threshold", state do
      vehicle_one = %Vehicle{
        vehicle_id: "1234",
        latitude: 42,
        longitude: -71,
        timestamp: 1
      }

      vehicle_two = %Vehicle{
        vehicle_id: "1234",
        latitude: 42.001,
        longitude: -71.001,
        timestamp: 101
      }

      fun = fn -> handle_cast({:validate_speed, vehicle_one, vehicle_two}, state) end

      expected_log = "Speed too high"

      refute capture_log(fun) =~ expected_log
    end
  end
end
