defmodule TrainLoc.Vehicles.Validator do
  alias TrainLoc.Vehicles.Vehicle
  
  def validate(%Vehicle{} = veh) do
    with \
      :ok <- must_be_non_neg_int(veh, :vehicle_id),
      :ok <- must_be_datetime(veh, :timestamp),
      :ok <- must_be_string(veh, :block),
      :ok <- must_be_string(veh, :trip),
      :ok <- must_be_float(veh, :latitude),
      :ok <- must_be_float(veh, :longitude),
      :ok <- must_be_in_range(veh, :heading, 0..359),
      :ok <- must_be_non_neg_int(veh, :speed),
      :ok <- must_be_in_range(veh, :fix, 0..9)
    do
      :ok
    else
      _ ->
        {:error, :invalid_vehicle}
    end
  end
  def validate(_other) do
    {:error, :not_a_vehicle}
  end

  def must_be_non_neg_int(veh, field) do
    case Map.get(veh, field) do
      x when is_integer(x) and x >= 0 ->
        :ok
      _ ->
        {:error, :invalid_vehicle}
    end
  end

  def must_be_string(veh, field) do
    case Map.get(veh, field) do
      "" ->
        {:error, :invalid_vehicle}
      x when is_binary(x) ->
        :ok
      _ -> 
        {:error, :invalid_vehicle}
    end
  end

  def must_be_datetime(veh, field) do
    case Map.get(veh, field) do
      %DateTime{} ->
        :ok
      _ ->
        {:error, :invalid_vehicle}
      end
  end

  def must_be_float(veh, field) do
    case Map.get(veh, field) do
      x when is_float(x) -> :ok
      _ ->
        {:error, :invalid_vehicle}        
    end
  end

  def must_be_in_range(veh, field, first..last) do
    case Map.get(veh, field) do
      x when x in first..last -> :ok
      _ ->
        {:error, :invalid_vehicle}
    end
  end

end
