defmodule Busloc.Operator.ParseTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Operator.Parse

  describe "parse/1" do
    setup do
      cmd = Busloc.Utilities.ConfigHelpers.config(Operator, :cmd)
      %{cmd: cmd}
    end

    test "parses results of SQL query into list of Operator", %{cmd: cmd} do
      expected = [
        %Busloc.Operator{
          vehicle_id: "0401",
          operator_name: "DIXON",
          operator_id: "65494",
          block: "Q225-84",
          run: "128-1407"
        },
        %Busloc.Operator{
          vehicle_id: "0417",
          operator_name: "WELCH",
          operator_id: "71925",
          block: "T86-136",
          run: "125-1401"
        },
        %Busloc.Operator{
          vehicle_id: "0422",
          operator_name: "THISTLE",
          operator_id: "72113",
          block: "F411-99",
          run: "126-0111"
        },
        %Busloc.Operator{
          vehicle_id: "0425",
          operator_name: "HENDRON",
          operator_id: "66261",
          block: "F96-24",
          run: "126-1403"
        },
        %Busloc.Operator{
          vehicle_id: "0428",
          operator_name: "BOND",
          operator_id: "71535",
          block: "F137-82",
          run: "126-0120"
        }
      ]

      assert parse(cmd.cmd()) == expected
    end
  end
end
