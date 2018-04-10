defmodule TrainLoc.Vehicles.JsonValidator do
  @moduledoc """
  This module validates types only for vehicle json
  and does not attempt to check valid ranges or configuration
  for any values.

  Any logic that checks value validity (other than simple types) should
  remain with the `Vehicle` struct validation.
  """

  def validate(json) when is_map(json) do
    with {:ok, heading} when is_integer(heading) <- Map.fetch(json, "Heading"),
         {:ok, speed} when is_integer(speed) <- Map.fetch(json, "Speed"),
         {:ok, latitude} when is_float(latitude) or is_integer(latitude) <-
           Map.fetch(json, "Latitude"),
         {:ok, longitude} when is_float(longitude) or is_integer(longitude) <-
           Map.fetch(json, "Longitude"),
         {:ok, updatetime} when is_binary(updatetime) <- Map.fetch(json, "Update Time"),
         {:ok, vehicleid} when is_integer(vehicleid) <- Map.fetch(json, "VehicleID"),
         {:ok, workid} when is_integer(workid) <- Map.fetch(json, "WorkID"),
         {:ok, tripid} when is_integer(tripid) <- Map.fetch(json, "TripID") do
      :ok
    else
      _ ->
        {:error, :invalid_vehicle_json}
    end
  end

  def validate(_) do
    {:error, :invalid_json}
  end
end
