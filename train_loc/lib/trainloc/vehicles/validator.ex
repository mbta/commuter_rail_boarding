defmodule TrainLoc.Vehicles.Validator do
  alias TrainLoc.Vehicles.Vehicle
  

  def validate(%Vehicle{} = veh) do
    with \
      :ok <- must_be_non_neg_int(veh, :vehicle_id),
      :ok <- must_be_datetime(veh, :timestamp),
      :ok <- must_be_non_neg_int(veh, :block),
      :ok <- must_be_string(veh, :trip),
      :ok <- must_be_float(veh, :latitude),
      :ok <- must_be_float(veh, :longitude),
      :ok <- must_be_in_range(veh, :heading, 0..359),
      :ok <- must_be_non_neg_int(veh, :speed),
      :ok <- must_be_in_range(veh, :fix_id, 0..9)
    do
      :ok
    else
      {:error, _} = error ->
        error
    end
  end

  def must_be_non_neg_int(veh, field) do
    case Map.get(veh, field) do
      x when is_integer(x) and x >= 0 ->
        :ok
      x ->
        {:error, %{
          expected: :non_negative_integer,
          got: x,
          field: field,
        }}
    end
  end

  def must_be_string(veh, field) do
    case Map.get(veh, field) do
      "" ->
        {:error, %{
          expected: :any_non_blank_string,
          got: "",
          field: field,
        }}
      x when is_binary(x) ->
        :ok
      x -> 
        {:error, %{
          expected: :any_non_blank_string,
          got: x,
          field: field,
        }}
    end
  end

  def must_be_datetime(veh, field) do
    case Map.get(veh, field) do
      %DateTime{} ->
        :ok
      x ->
        {:error, %{
          expected: :datetime_struct,
          got: x,
          field: field,
        }}
    end
  end

  def must_be_float(veh, field) do
    case Map.get(veh, field) do
      x when is_float(x) -> :ok
      x ->
        {:error, %{expected: :float, got: x, field: field}}
    end
  end

  def must_be_in_range(veh, field, first..last) do
    case Map.get(veh, field) do
      x when x in first..last -> :ok
      x ->
        {:error, %{
          expected: :to_be_in_range,
          got: x,
          field: field,
          range_start: first,
          range_stop: last,
        }}
        
    end
  end

end
