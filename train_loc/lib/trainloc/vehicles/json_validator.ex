defmodule TrainLoc.Vehicles.JsonValidator do
  @moduledoc """
  This module validates types only for vehicle json
  and does not attempt to check valid ranges or configuration
  for any values.

  Any logic that checks value validity (other than simple types) should
  remain with the `Vehicle` struct validation.
  """

  def validate(json) when is_map(json) do
    with \
      {:ok, fix}        when is_integer(fix)        <- Map.fetch(json, "fix"),
      {:ok, heading}    when is_integer(heading)    <- Map.fetch(json, "heading"),
      {:ok, speed}      when is_integer(speed)      <- Map.fetch(json, "speed"),
      {:ok, latitude}   when is_integer(latitude)   <- Map.fetch(json, "latitude"),
      {:ok, longitude}  when is_integer(longitude)  <- Map.fetch(json, "longitude"),
      {:ok, updatetime} when is_integer(updatetime) <- Map.fetch(json, "updatetime"),
      {:ok, vehicleid}  when is_integer(vehicleid)  <- Map.fetch(json, "vehicleid"),
      {:ok, workid}     when is_integer(workid)     <- Map.fetch(json, "workid"),
      {:ok, routename}  when is_binary(routename)   <- Map.fetch(json, "routename")
    do
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