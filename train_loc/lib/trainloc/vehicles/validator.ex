defmodule TrainLoc.Vehicles.Validator do
  @moduledoc """
  Intended to validate the expected data ranges and
  expected values that a vehicle is allowed to have.
  """
  alias TrainLoc.Vehicles.Vehicle

  @default_error {:error, :invalid_vehicle}

  @doc """
  Validates a vehicles to ensure expected values.

  Any discrepancy between expected values and actual values results
  in an error tuple `{:error, reason}` where `reason` is an atom.

  A valid vehicle will result in an `:ok`.
  """
  def validate(%Vehicle{} = veh) do
    with \
      :ok <- must_be_non_neg_int(veh, :vehicle_id),
      :ok <- must_be_datetime(veh, :timestamp),
      :ok <- must_be_string(veh, :block),
      :ok <- must_not_be_blank(veh, :block),
      :ok <- must_be_string(veh, :trip),
      :ok <- must_not_be_blank(veh, :trip),
      :ok <- must_have_valid_latitude(veh),
      :ok <- must_have_valid_longitude(veh),
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

  defp run_validation(veh, field, bool_func) when is_function(bool_func, 1) do
    if veh |> Map.get(field) |> bool_func.() do
      :ok
    else
      @default_error
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

  @doc """
  Validates the type and range value of a Vehicles latitude.

  The outhernmost station is Wickford Junction (41.5).

  The northernmost station is Newburyport (42.8).
  """
  def must_have_valid_latitude(%Vehicle{latitude: lat}) when is_float(lat) and lat >= 41.5 and lat <= 42.8 do
    :ok
  end
  def must_have_valid_latitude(_) do
    @default_error
  end

  @doc """
  Validates the type and range value of a Vehicles longitude.

  The westernmost station is Wachusett (-72).

  The easternmost station depends on whether the summer
  CapeFLYER trains use vehicles that appear in this
  feed - either Rockport (-70.6) or Hyannis (-70.25). In this
  case, Hyannis (-70.25) was chosen because it is more permissive.
  """
  def must_have_valid_longitude(%Vehicle{longitude: long}) when is_float(long) and long >= -72.0 and long <= -70.25 do
    :ok
  end
  def must_have_valid_longitude(_) do
    @default_error
  end
end
