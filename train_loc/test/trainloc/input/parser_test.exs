defmodule TrainLoc.Input.ParserTest do
    alias TrainLoc.Input.Parser
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Vehicles.Vehicle.GPS
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
            %Vehicle{
                vehicle_id: "1625",
                timestamp: ~N[2017-08-04 11:01:48],
                operator: "0",
                block: "0",
                trip: "0",
                gps: %GPS{
                    time: 54106,
                    lat: 42.37434,
                    long: -71.07818,
                    speed: 0,
                    heading: 280,
                    source: 1,
                    age: 2
                }
           }, %Vehicle{
                vehicle_id: "1716",
                timestamp: ~N[2017-08-04 11:01:49],
                operator: "910",
                block: "0",
                trip: "9999",
                gps: %GPS{
                    time: 54105,
                    lat: 42.33913,
                    long: -71.06041,
                    speed: 6,
                    heading: 318,
                    source: 1,
                    age: 1
                }
            }, %Vehicle{
                vehicle_id: "1717",
                timestamp: ~N[2017-08-04 11:01:50],
                operator: "910",
                block: "0",
                trip: "9999",
                gps: %GPS{
                    time: 54107,
                    lat: 42.34021,
                    long: -71.06019,
                    speed: 5,
                    heading: 177,
                    source: 1,
                    age: 2
                }
            }, %Vehicle{
                vehicle_id: "1644",
                timestamp: ~N[2017-08-04 11:01:50],
                operator: "910",
                block: "154",
                trip: "315",
                gps: %GPS{
                    time: 54107,
                    lat: 42.36658,
                    long: -71.06287,
                    speed: 5,
                    heading: 173,
                    source: 1,
                    age: 1
                }
            }, %Vehicle{
                vehicle_id: "1712",
                timestamp: ~N[2017-08-04 11:01:51],
                operator: "910",
                block: "802",
                trip: "509",
                gps: %GPS{
                    time: 54109,
                    lat: 42.24023,
                    long: -71.12890,
                    speed: 0,
                    heading: 188,
                    source: 1,
                    age: 2
                }
            }
        ]
    end
end
