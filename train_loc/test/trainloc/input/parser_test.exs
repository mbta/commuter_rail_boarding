defmodule TrainLoc.Input.ParserTest do
    alias TrainLoc.Input.Parser
    use ExUnit.Case, async: true
    doctest Parser

    test "parses line from PTIS" do
        good_result = Parser.parse_line("08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+4224023-0711289000018812<]")
        assert good_result == %{
            "vehicle_id" => "1712",
            "timestamp" => "08-04-2017 11:01:51 AM",
            "type" => "Location",
            "operator" => "910",
            "workpiece" => "802",
            "pattern" => "509",
            "time" => "54109",
            "lat" => "+4224023",
            "long" => "-07112890",
            "speed" => "000",
            "heading" => "188",
            "source" => "1",
            "age" => "2"
        }
        #line truncated within timestamp
        bad_result_one = Parser.parse_line("08-0")
        assert bad_result_one == nil

        #line truncated within Vehicle ID clause
        bad_result_two = Parser.parse_line("08-04-2017 11:01:51 AM	Vehic")
        assert bad_result_two == nil

        #line truncated arbitrarily within Location object
        bad_result_three = Parser.parse_line("08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpie")
        assert bad_result_three == nil

        #line truncated within GPS data
        bad_result_four = Parser.parse_line("08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+42")
        assert bad_result_four == nil
    end

    test "parses PTIS file" do
        test_file_contents = """
        08-04-2017 11:01:48 AM	Vehicle ID:1625 - Location[Operator:0, Workpiece:0, Pattern:0, GPS:>RPV54106+4237434-0710781800028012<]
        08-04-2017 11:01:48 AM	Vehicle ID:1651 - Initialize Pattern Ack[Operator:910, Workpiece:104, Pattern:109, Status:0, Seq:11]
        08-04-2017 11:01:49 AM	Vehicle ID:1822 - SAM Ack[ID:210, Type:0, Seq:1501833210]
        08-04-2017 11:01:49 AM	Vehicle ID:1716 - Location[Operator:910, Workpiece:0, Pattern:9999, GPS:>RPV54105+4233913-0710604100631811<]
        08-04-2017 11:01:50 AM	Vehicle ID:1717 - Location[Operator:910, Workpiece:0, Pattern:9999, GPS:>RPV54107+4234021-0710601900517712<]
        08-04-2017 11:01:50 AM	Vehicle ID:1644 - Location[Operator:910, Workpiece:154, Pattern:315, GPS:>RPV54107+4236658-0710628700517311<]
        08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+4224023-0711289000018812<]
        08-0
        """
        assert Parser.parse(test_file_contents) == [
            %{
                "vehicle_id" => "1625",
                "timestamp" => "08-04-2017 11:01:48 AM",
                "type" => "Location",
                "operator" => "0",
                "workpiece" => "0",
                "pattern" => "0",
                "time" => "54106",
                "lat" => "+4237434",
                "long" => "-07107818",
                "speed" => "000",
                "heading" => "280",
                "source" => "1",
                "age" => "2"
           }, %{
                "vehicle_id" => "1716",
                "timestamp" => "08-04-2017 11:01:49 AM",
                "type" => "Location",
                "operator" => "910",
                "workpiece" => "0",
                "pattern" => "9999",
                "time" => "54105",
                "lat" => "+4233913",
                "long" => "-07106041",
                "speed" => "006",
                "heading" => "318",
                "source" => "1",
                "age" => "1"
            }, %{
                "vehicle_id" => "1717",
                "timestamp" => "08-04-2017 11:01:50 AM",
                "type" => "Location",
                "operator" => "910",
                "workpiece" => "0",
                "pattern" => "9999",
                "time" => "54107",
                "lat" => "+4234021",
                "long" => "-07106019",
                "speed" => "005",
                "heading" => "177",
                "source" => "1",
                "age" => "2"
            }, %{
                "vehicle_id" => "1644",
                "timestamp" => "08-04-2017 11:01:50 AM",
                "type" => "Location",
                "operator" => "910",
                "workpiece" => "154",
                "pattern" => "315",
                "time" => "54107",
                "lat" => "+4236658",
                "long" => "-07106287",
                "speed" => "005",
                "heading" => "173",
                "source" => "1",
                "age" => "1"
            }, %{
                "vehicle_id" => "1712",
                "timestamp" => "08-04-2017 11:01:51 AM",
                "type" => "Location",
                "operator" => "910",
                "workpiece" => "802",
                "pattern" => "509",
                "time" => "54109",
                "lat" => "+4224023",
                "long" => "-07112890",
                "speed" => "000",
                "heading" => "188",
                "source" => "1",
                "age" => "2"
            }
        ]
    end
end
