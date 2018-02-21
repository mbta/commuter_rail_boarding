defmodule TrainLoc.Vehicles.ValidatorTest do
  use ExUnit.Case, async: true
  alias TrainLoc.Vehicles.{Validator, Vehicle}
  import TrainLoc.Utilities.ConfigHelpers
  

  describe "must_be_non_neg_int/2" do
    test "fails on non-integer" do
      params = %{the_field: "123"}
      expected = {:error, :invalid_vehicle}
      result = Validator.must_be_non_neg_int(params, :the_field) 
      assert result == expected
    end

    test "fails on negative integer" do
      params = %{the_field: -1}
      expected = {:error, :invalid_vehicle}
      result = Validator.must_be_non_neg_int(params, :the_field) 
      assert result == expected
    end

    test "works on 0" do
      params = %{the_field: 0}
      expected = :ok
      result = Validator.must_be_non_neg_int(params, :the_field) 
      assert result == expected
    end

    test "works for non-neg-integer" do
      params = %{the_field: 1}
      expected = :ok
      result = Validator.must_be_non_neg_int(params, :the_field) 
      assert result == expected
    end
  end

  describe "must_be_datetime/2" do
    test "works for DateTime structs" do
      params = %{the_field: DateTime.utc_now()}
      expected = :ok
      result = Validator.must_be_datetime(params, :the_field) 
      assert result == expected
    end

    test "fails for any non-DateTime-struct" do
      params = %{the_field: 0}
      expected = {:error, :invalid_vehicle}
      result = Validator.must_be_datetime(params, :the_field) 
      assert result == expected
    end
  end

  describe "must_be_float/2" do
    test "works for floats" do
      params = %{the_field: 1.1}
      expected = :ok
      result = Validator.must_be_float(params, :the_field) 
      assert result == expected
    end

    test "fails for non-floats" do
      params = %{the_field: :other}
      expected = {:error, :invalid_vehicle}
      result = Validator.must_be_float(params, :the_field) 
      assert result == expected
    end
  end

  describe "must_be_in_range/3" do
    test "works for an int in a range" do
      params = %{the_field: 1}
      expected = :ok
      result = Validator.must_be_in_range(params, :the_field, 0..1) 
      assert result == expected
    end

    test "fails for an non-int" do
      params = %{the_field: "not_an_int"}
      expected = {:error, :invalid_vehicle}
      result = Validator.must_be_in_range(params, :the_field, 0..1) 
      assert result == expected
    end

    test "fails for an int that is out of range" do
      params = %{the_field: 2}
      expected = {:error, :invalid_vehicle}
      result = Validator.must_be_in_range(params, :the_field, 0..1) 
      assert result == expected
    end
  end

  describe "is_datetime?/1" do
    test "works on DateTime structs" do
      date = DateTime.utc_now()
      assert Validator.is_datetime?(date) == true
    end

    test "fails on non-DateTime structs" do
      assert Validator.is_datetime?("not_a_date") == false
    end
  end

  describe "is_non_neg_int?/1" do
    test "true on positive integer" do
      assert Validator.is_non_neg_int?(1) == true
      assert Validator.is_non_neg_int?(100) == true
    end

    test "true on 0" do
      assert Validator.is_non_neg_int?(0) == true
    end

    test "false on negative integer" do
      assert Validator.is_non_neg_int?(-1) == false
      assert Validator.is_non_neg_int?(-100) == false
    end

    test "false on other than integer" do
      assert Validator.is_non_neg_int?("other") == false
      assert Validator.is_non_neg_int?(:other) == false
    end
  end

  describe "is_blank?/1" do
    test "true on empty string" do
      assert Validator.is_blank?("") == true
    end

    test "true on nil" do
      assert Validator.is_blank?(nil) == true
    end

    test "false on anything other than nil or false" do
      assert Validator.is_blank?("not_blank") == false
    end
  end

  describe "is_not_blank?/1" do
    test "false on empty string" do
      assert Validator.is_not_blank?("") == false
    end

    test "false on nil" do
      assert Validator.is_not_blank?(nil) == false
    end

    test "true on anything other than nil or false" do
      assert Validator.is_not_blank?("not_blank") == true
    end
  end


  describe "validate/1" do
    @time_format config(:time_format)    
    @valid_timestamp Timex.parse!("2018-01-05 11:38:50 America/New_York", @time_format)
    @valid_vehicle %Vehicle{
      block: "602",
      fix: 1,
      heading: 48,
      latitude: 42.28179,
      longitude: -71.15936,
      speed: 14,
      timestamp: @valid_timestamp,
      trip: "612",
      vehicle_id: 1827,
    }
    test "works for valid structs" do
      assert Validator.validate(@valid_vehicle) == :ok
    end

    test "fails for non-structs" do
      assert Validator.validate("other") == {:error, :not_a_vehicle}
    end

    test "fails for invalid structs" do
      result =
        @valid_vehicle
        |> Map.put(:trip, nil)
        |> Validator.validate
      assert result == {:error, :invalid_vehicle}
    end
  end
end
