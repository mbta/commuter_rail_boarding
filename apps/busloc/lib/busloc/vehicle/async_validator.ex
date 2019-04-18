defmodule Busloc.Vehicle.AsyncValidator do
  use GenServer

  import Busloc.Utilities.ConfigHelpers
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def validate_speed(vehicle_one, vehicle_two) do
    GenServer.cast(__MODULE__, {:validate_speed, vehicle_one, vehicle_two})
  end

  def init(_) do
    state = %{ang_speed_threshold: config(AsyncValidator, :ang_speed_threshold)}
    {:ok, state}
  end

  def handle_cast(
        {:validate_speed, vehicle_one, vehicle_two},
        %{ang_speed_threshold: threshold} = state
      ) do
    distance =
      :math.sqrt(
        :math.pow(vehicle_one.latitude - vehicle_two.latitude, 2) +
          :math.pow(vehicle_one.longitude - vehicle_two.longitude, 2)
      )

    speed = distance / abs(vehicle_one.timestamp - vehicle_two.timestamp)

    if speed > threshold do
      Logger.warn(fn ->
        "Speed too high - v_id=#{vehicle_one.vehicle_id} time=#{
          max(vehicle_one.timestamp, vehicle_two.timestamp)
        }"
      end)
    end

    {:noreply, state}
  end
end
