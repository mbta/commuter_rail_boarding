defmodule Busloc.Filter do
  @moduledoc """
  Filters a list of %Vehicles{} so that we only render the ones we care about.
  """
  alias Busloc.Vehicle

  @spec filter([Vehicle.t()], DateTime.t()) :: [Vehicle.t()]
  def filter(vehicles, now) do
    for vehicle <- vehicles, Vehicle.validate_time(vehicle, now) == :ok do
      vehicle
    end
  end
end