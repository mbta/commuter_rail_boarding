defmodule TrainLoc.Vehicles.JsonValidator do

  def validate(json) when is_map(json) do
    with \
      {:ok, fix}        when is_integer(fix) and fix in 0..9  <- Map.fetch(json, "fix"),
      {:ok, heading}    when is_integer(heading)              <- Map.fetch(json, "heading"),
      {:ok, latitude}   when is_integer(latitude)             <- Map.fetch(json, "latitude"),
      {:ok, longitude}  when is_integer(longitude)            <- Map.fetch(json, "longitude"),
      {:ok, speed}      when is_integer(speed) and speed >= 0 <- Map.fetch(json, "speed"),
      {:ok, updatetime} when is_integer(updatetime)           <- Map.fetch(json, "updatetime"),
      {:ok, vehicleid}  when is_integer(vehicleid)            <- Map.fetch(json, "vehicleid"),
      {:ok, workid}     when is_integer(workid)               <- Map.fetch(json, "workid"),
      {:ok, routename}  when is_binary(routename)             <- Map.fetch(json, "routename")
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