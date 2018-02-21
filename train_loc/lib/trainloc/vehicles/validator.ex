defmodule TrainLoc.Vehicles.Validator do
  alias TrainLoc.Vehicles.Vehicle
  
  def validate(%Vehicle{} = veh) do
    with \
      :ok <- must_be_non_neg_int(veh, :vehicle_id),
      :ok <- must_be_datetime(veh, :timestamp),
      :ok <- must_be_string(veh, :block),
      :ok <- must_not_be_blank(veh, :block),
      :ok <- must_be_string(veh, :trip),
      :ok <- must_not_be_blank(veh, :trip),
      :ok <- must_be_float(veh, :latitude),
      :ok <- must_be_float(veh, :longitude),
      :ok <- must_be_in_range(veh, :heading, 0..359),
      :ok <- must_be_non_neg_int(veh, :speed),
      :ok <- must_be_in_range(veh, :fix, 0..9)
    do
      :ok
    end
  end
  def validate(_other) do
    {:error, :not_a_vehicle}
  end

  defp run_validation(veh, field, bool_func, error \\ {:error, :invalid_vehicle}) when is_function(bool_func, 1) do
    if veh |> Map.get(field) |> bool_func.() do
      :ok
    else
      error
    end
  end

  def is_non_neg_int?(x) do
    is_integer(x) and x >= 0
  end

  def is_blank?(""), do: true
  def is_blank?(nil), do: true
  def is_blank?(_), do: false

  def is_not_blank?(x), do: !is_blank?(x)

  def is_datetime?(%DateTime{}), do: true
  def is_datetime?(_), do: false

  def must_be_non_neg_int(veh, field) do
    run_validation(veh, field, &is_non_neg_int?/1)
  end

  def must_be_string(veh, field) do
    run_validation(veh, field, &is_binary/1)
  end

  def must_not_be_blank(veh, field) do
    run_validation(veh, field, &is_not_blank?/1)
  end

  def must_be_datetime(veh, field) do
    run_validation(veh, field, &is_datetime?/1)
  end

  def must_be_float(veh, field) do
    run_validation(veh, field, &is_float/1)
  end

  def must_be_in_range(veh, field, _.._ = range) do
    in_range? = fn (x) -> x in range end
    run_validation(veh, field, in_range?)
  end

end
