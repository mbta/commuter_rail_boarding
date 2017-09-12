defmodule TrainLoc.ParserTest do
    alias TrainLoc.Parser
    use ExUnit.Case, async: true
    doctest Parser

    test "parses line from PTIS" do
        good_result = Parser.parse_line("08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+4224023-0711289000018812<]")
        assert good_result == {:ok,
        %{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:01:51],
            type: "Location",
            operator: "910",
            workpiece: "802",
            pattern: "509",
            gps: %{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 0,
                heading: 188,
                source: 1,
                age: 2
            }
        }}
        #line truncated within timestamp
        bad_result_one = Parser.parse_line("08-0")
        assert bad_result_one == {:error, :eshortline}

        #line truncated within Vehicle ID clause
        bad_result_two = Parser.parse_line("08-04-2017 11:01:51 AM	Vehic")
        assert bad_result_two == {:error, :eshortline}

        #line truncated arbitrarily within Location object
        bad_result_three = Parser.parse_line("08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpie")
        assert bad_result_three == {:error, :eshortline}

        #line truncated within GPS data
        bad_result_four = Parser.parse_line("08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+42")
        assert bad_result_four == {:error, :eshortline}
    end

    test "separates colon-separated parameters" do
        assert Parser.split_by_colon("Operator:910") == "910"
    end

    test "parses data from PTIS Location entry" do
        {:ok, result} = Parser.parse_msg_body("Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+4224023-0711289000018812<]")
        assert result ==
            %{
                type: "Location",
                operator: "910",
                workpiece: "802",
                pattern: "509",
                gps: %{
                    time: 54109,
                    lat: 42.24023,
                    long: -71.12890,
                    speed: 0,
                    heading: 188,
                    source: 1,
                    age: 2
                }
            }
        {:ok, result} = Parser.parse_msg_body("SAM[Operator:910, Workpiece:742, Pattern:712, ID:210, Type:1, Seq:1501833210, GPS:>RPV54105+4208039-0714003802604812<]")
        assert result == %{type: "SAM", data: "Operator:910, Workpiece:742, Pattern:712, ID:210, Type:1, Seq:1501833210, GPS:>RPV54105+4208039-0714003802604812<"}
    end

    test "parses TAIP GPS data" do
        {:ok, result} = Parser.parse_gps(">RPV54109+4224023-0711289000018812<")
        assert result == %{
            time: 54109,
            lat: 42.24023,
            long: -71.12890,
            speed: 0,
            heading: 188,
            source: 1,
            age: 2
        }
    end

    test "parses PTIS file" do
        assert Parser.parse_file("data/test-AVL.txt") == [
            %{vehicle_id: "1712", timestamp: ~N[2017-08-04 11:01:51], type: "Location", operator: "910", workpiece: "802", pattern: "509",
                gps: %{time: 54109, lat: 42.24023, long: -71.12890, speed: 0, heading: 188, source: 1, age: 2}},
            %{vehicle_id: "1644", timestamp: ~N[2017-08-04 11:01:50], type: "Location", operator: "910", workpiece: "154", pattern: "315",
                gps: %{time: 54107, lat: 42.36658, long: -71.06287, speed: 5, heading: 173, source: 1, age: 1}},
            %{vehicle_id: "1717", timestamp: ~N[2017-08-04 11:01:50], type: "Location", operator: "910", workpiece: "0", pattern: "9999",
                gps: %{time: 54107, lat: 42.34021, long: -71.06019, speed: 5, heading: 177, source: 1, age: 2}},
            %{vehicle_id: "1716", timestamp: ~N[2017-08-04 11:01:49], type: "Location", operator: "910", workpiece: "0", pattern: "9999",
                gps: %{time: 54105, lat: 42.33913, long: -71.06041, speed: 6, heading: 318, source: 1, age: 1}},
            %{vehicle_id: "1822", timestamp: ~N[2017-08-04 11:01:49], type: "SAM Ack", data: "ID:210, Type:0, Seq:1501833210"},
            %{vehicle_id: "1651", timestamp: ~N[2017-08-04 11:01:48], type: "Initialize Pattern Ack", data: "Operator:910, Workpiece:104, Pattern:109, Status:0, Seq:11"},
            %{vehicle_id: "1625", timestamp: ~N[2017-08-04 11:01:48], type: "Location", operator: "0", workpiece: "0", pattern: "0",
                gps: %{time: 54106, lat: 42.37434, long: -71.07818, speed: 0, heading: 280, source: 1, age: 2}}
        ]
    end
end
