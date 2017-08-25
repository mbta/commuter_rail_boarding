defmodule ParserTest do
    use ExUnit.Case
    doctest Parser

    test "parses line from PTIS" do
        good_result = Parser.parse_line("08-04-2017 11:01:51 AM	Vehicle ID:1712 - Location[Operator:910, Workpiece:802, Pattern:509, GPS:>RPV54109+4224023-0711289000018812<]")
        assert good_result == {:ok,
            %{
                timestamp: ~N[2017-08-04 11:01:51],
                vehicle_id: "1712",
                type: "Location",
                operator: "910",
                workpiece: "802",
                pattern: "509",
                gps: %{
                    time: "54109",
                    lat: "+4224023",
                    long: "-07112890",
                    speed: "000",
                    heading: "188",
                    source: "1",
                    age: "2"
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
                    time: "54109",
                    lat: "+4224023",
                    long: "-07112890",
                    speed: "000",
                    heading: "188",
                    source: "1",
                    age: "2"
                }
            }
        {:ok, result} = Parser.parse_msg_body("SAM[Operator:910, Workpiece:742, Pattern:712, ID:210, Type:1, Seq:1501833210, GPS:>RPV54105+4208039-0714003802604812<]")
        assert result == %{type: "SAM"}
    end

    test "parses TAIP GPS data" do
        {:ok, result} = Parser.parse_gps(">RPV54109+4224023-0711289000018812<")
        assert result == %{
            time: "54109",
            lat: "+4224023",
            long: "-07112890",
            speed: "000",
            heading: "188",
            source: "1",
            age: "2"
        }
    end

    test "parses PTIS file" do
        assert Parser.parse_file("data/test-AVL.txt") == [
            %{timestamp: ~N[2017-08-04 11:01:51], vehicle_id: "1712", type: "Location", operator: "910", workpiece: "802", pattern: "509",
                gps: %{time: "54109", lat: "+4224023", long: "-07112890", speed: "000", heading: "188", source: "1", age: "2"}},
            %{timestamp: ~N[2017-08-04 11:01:50], vehicle_id: "1644", type: "Location", operator: "910", workpiece: "154", pattern: "315",
                gps: %{time: "54107", lat: "+4236658", long: "-07106287", speed: "005", heading: "173", source: "1", age: "1"}},
            %{timestamp: ~N[2017-08-04 11:01:50], vehicle_id: "1717", type: "Location", operator: "910", workpiece: "0", pattern: "9999",
                gps: %{time: "54107", lat: "+4234021", long: "-07106019", speed: "005", heading: "177", source: "1", age: "2"}},
            %{timestamp: ~N[2017-08-04 11:01:49], vehicle_id: "1716", type: "Location", operator: "910", workpiece: "0", pattern: "9999",
                gps: %{time: "54105", lat: "+4233913", long: "-07106041", speed: "006", heading: "318", source: "1", age: "1"}},
            %{timestamp: ~N[2017-08-04 11:01:49], vehicle_id: "1822", type: "SAM Ack"},
            %{timestamp: ~N[2017-08-04 11:01:48], vehicle_id: "1651", type: "Initialize Pattern Ack"},
            %{timestamp: ~N[2017-08-04 11:01:48], vehicle_id: "1625", type: "Location", operator: "0", workpiece: "0", pattern: "0",
                gps: %{time: "54106", lat: "+4237434", long: "-07107818", speed: "000", heading: "280", source: "1", age: "2"}}
        ]
    end
end
