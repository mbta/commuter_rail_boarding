defmodule TrainLoc.Vehicles.ValidatorTest do
  # use ExUnit.Case, async: true
  # alias TrainLoc.Vehicles.Validator

  # @type t :: %__MODULE__{
  #   vehicle_id: non_neg_integer,
  #   timestamp: DateTime.t,
  #   block: non_neg_integer,
  #   trip: String.t,
  #   latitude: float,
  #   longitude: float,
  #   heading: 0..359,
  #   speed: non_neg_integer,
  #   fix: fix_id # 0..9
  # }

  # describe "must_be_non_neg_int/2" do

  #   test "fails on non-integer" do
  #     params = %{the_field: "123"}
  #     expected = {:error,
  #       %{expected: :non_negative_integer, field: :the_field, got: "123"}
  #     }
  #     result = Validator.must_be_non_neg_int(params, :the_field) 
  #     assert result == expected
  #   end

  #   test "fails on negative integer" do
  #     params = %{the_field: -1}
  #     expected = {:error,
  #       %{expected: :non_negative_integer, field: :the_field, got: -1}
  #     }
  #     result = Validator.must_be_non_neg_int(params, :the_field) 
  #     assert result == expected
  #   end

  #   test "works on 0" do
  #     params = %{the_field: 0}
  #     expected = :ok
  #     result = Validator.must_be_non_neg_int(params, :the_field) 
  #     assert result == expected
  #   end

  #   test "works for non-neg-integer" do
  #     params = %{the_field: 1}
  #     expected = :ok
  #     result = Validator.must_be_non_neg_int(params, :the_field) 
  #     assert result == expected
  #   end

  # end

  # describe "must_be_datetime/2" do

  #   test "works for DateTime structs" do
  #     params = %{the_field: DateTime.utc_now()}
  #     expected = :ok
  #     result = Validator.must_be_datetime(params, :the_field) 
  #     assert result == expected
  #   end

  #   test "fails for any non-DateTime-struct" do
  #     params = %{the_field: 0}
  #     expected = {:error, %{expected: :datetime_struct, field: :the_field, got: 0}}
  #     result = Validator.must_be_datetime(params, :the_field) 
  #     assert result == expected
  #   end
  # end
  # describe "must_be_float/2" do
  #   test "works for floats" do
  #     params = %{the_field: 1.1}
  #     expected = :ok
  #     result = Validator.must_be_float(params, :the_field) 
  #     assert result == expected
  #   end
  #   test "fails for non-floats" do
  #     params = %{the_field: :other}
  #     expected = {:error, %{expected: :float, field: :the_field, got: :other}}
  #     result = Validator.must_be_float(params, :the_field) 
  #     assert result == expected
  #   end
  # end
  # describe "must_be_in_range/3" do
  #   test "works for an int in a range" do
  #     params = %{the_field: 1}
  #     expected = :ok
  #     result = Validator.must_be_in_range(params, :the_field, 0..1) 
  #     assert result == expected
  #   end
  #   test "fails for an non-int" do
  #     params = %{the_field: "not_an_int"}
  #     error_map = %{
  #       expected: :to_be_in_range,
  #       field: :the_field,
  #       got: "not_an_int",
  #       range_start: 0,
  #       range_stop: 1,
  #     }
  #     expected = {:error, error_map}
  #     result = Validator.must_be_in_range(params, :the_field, 0..1) 
  #     assert result == expected
  #   end
  #   test "fails for an int that is out of range" do
  #     params = %{the_field: 2}
  #     error_map = %{
  #       expected: :to_be_in_range,
  #       field: :the_field,
  #       got: 2,
  #       range_start: 0,
  #       range_stop: 1,
  #     }
  #     expected = {:error, error_map}
  #     result = Validator.must_be_in_range(params, :the_field, 0..1) 
  #     assert result == expected
  #   end
  # end

  # # TODO: Write tests for validate/1

  # # describe "validate/1" do
  # #   test "works for valid structs"
  # #   test "fails for invalid structs"
  # # end

end