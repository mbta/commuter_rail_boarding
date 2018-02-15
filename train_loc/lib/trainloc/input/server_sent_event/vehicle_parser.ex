defmodule TrainLoc.Input.ServerSentEvent.VehicleParser do
  
  def parse(json) when is_list(json) do 
    Enum.reduce(json, {[], []}, fn item, {old_vehicles, old_errors} ->
      {new_vehicles, new_errors} = parse(item)
      {old_vehicles ++ new_vehicles, old_errors ++ new_errors}
    end)
  end
  def parse(json) when is_map(json) do
    case TrainLoc.Vehicles.Schema.from_keolis_json(json) do
      {:ok, schema} ->
        vehicle = TrainLoc.Vehicles.Schema.to_vehicle_struct(schema)
        {[vehicle], []}
      {:error, errors} when is_list(errors) ->
        {[], errors}
      {:error, error} ->
        {[], [error]}
    end
  end
  def parse(got) do
    {:error, %{
      expected: :map,
      reason: "Vehicle JSON must be a map/object",
      got: got,
    }}
  end


end