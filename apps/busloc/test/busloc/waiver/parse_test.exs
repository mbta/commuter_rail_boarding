defmodule Busloc.Waiver.ParseTest do
  use ExUnit.Case, async: true
  import Busloc.Waiver.Parse
  alias Busloc.Waiver

  describe "parse/1" do
    test "parses the sample data into %Waiver{} structs" do
      data = File.read!("test/data/waivers.csv")
      results = parse(data)

      for w <- results do
        assert %Waiver{} = w
      end

      assert length(results) == 2
    end
  end

  describe "to_waiver/1" do
    test "strips a leading 0 from a route ID" do
      map = %{
        "ROUTE_ID" => "09",
        "TRIP_ID" => "12345",
        "STOP_ID" => "56789",
        "UPDATED_AT" => "1970-01-01 00:00:00.000",
        "BLOCK_ID" => "T123-45",
        "REMARK" => "",
        "EARLY_ALLOWED_FLAG" => "0",
        "LATE_ALLOWED_FLAG" => "0",
        "MISSED_ALLOWED_FLAG" => "0",
        "NO_REVENUE_FLAG" => "0"
      }

      [waiver] = to_waiver(map)
      assert waiver.route_id == "9"
    end
  end
end
