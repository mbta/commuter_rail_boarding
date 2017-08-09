defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  test "parses line from PTIS" do
    assert Parser.parse_line("08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+4224023-0711289000018812<]") ==
        {~N[2017-08-04 11:01:51], "1712", "Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+4224023-0711289000018812<]"}
  end
end
