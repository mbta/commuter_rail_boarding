defmodule TrainLoc.Input.Parser do
    @moduledoc """
    Parser for PTIS data
    """

    @spec parse_line(String.t) :: {:ok, map} | {:error, term}
    def parse_line(line) do
        if String.length(line) == 0 do
            {:ok, nil} #input file might have blank lines between records, so they shouldn't cause parsing to halt like an incomplete line
        else
            split_line = String.split(line, " - ")
            line_prefix = Enum.at(split_line,0)
            if String.length(line_prefix) == 38 do
                split_prefix = String.split(line_prefix, "\t")
                timestamp = case split_prefix |> Enum.at(0) |> Timex.parse("{0M}-{0D}-{YYYY} {0h12}:{0m}:{0s} {AM}") do
                    {:ok, result} -> result
                    {:error, reason} -> {:error, reason}
                end
                if timestamp == {:error, :eshortline} do
                    timestamp
                else
                    vehicle_id = split_prefix |> Enum.at(1) |> split_by_colon()
                    case split_line |> Enum.at(1) |> parse_msg_body() do
                        {:ok, parsed_body} -> {:ok, Map.merge(%{vehicle_id: vehicle_id, timestamp: timestamp}, parsed_body)}
                        {:error, reason} -> {:error, reason}
                    end
                end
            else
                {:error, :eshortline}
            end
        end
    end

    @spec parse_msg_body(String.t) :: {:ok, map} | {:error, term}
    def parse_msg_body(data) do
        [type, body] = String.split(data, "[")
        data_map = %{type: type}
        if Map.get(data_map, :type) == "Location" do
            split_body = body |> String.split_at(-1) |> elem(0) |> String.split(", ")
            if length(split_body) == 4 do
                [operator_clause, workpiece_clause, pattern_clause, gps_clause] = split_body
                gps_parse_result = gps_clause |> String.split(":") |> Enum.at(1) |> parse_gps()
                parsed_gps = case gps_parse_result do
                    {:error, reason} -> {:error, reason}
                    {:ok, result} -> result
                end
                if parsed_gps == {:error, :eshortline} do
                    parsed_gps
                else
                    {:ok, Map.merge(data_map, %{operator: split_by_colon(operator_clause), workpiece: split_by_colon(workpiece_clause), pattern: split_by_colon(pattern_clause), gps: parsed_gps})}
                end
            else
                {:error, :eshortline}
            end
        else
            {:ok, Map.put(data_map, :data, body |> String.split("]") |> Enum.at(0))}
        end
    end

    @spec split_by_colon(String.t) :: String.t
    def split_by_colon(input) do
        Enum.at(String.split(input, ":"), 1)
    end

    @spec parse_gps(String.t) :: {:ok, map} | {:error, term}
    def parse_gps(gps_data) do
        if String.starts_with?(gps_data, ">RPV") and String.length(gps_data) >= 35 do
            {_, rest} = String.split_at(gps_data, 4)
            {time_string, rest} = String.split_at(rest, 5)
            {lat_string, rest} = String.split_at(rest, 8)
            {long_string, rest} = String.split_at(rest, 9)
            {speed_string, rest} = String.split_at(rest, 3)
            {heading_string, rest} = String.split_at(rest, 3)
            {source_string, rest} = String.split_at(rest, 1)
            {age_string, _} = String.split_at(rest, 1)

            time = String.to_integer(time_string)
            {big_lat, _} = Float.parse(lat_string)
            lat = big_lat / 100000
            {big_long, _} = Float.parse(long_string)
            long = big_long / 100000
            speed = String.to_integer(speed_string)
            heading = String.to_integer(heading_string)
            source = String.to_integer(source_string)
            age = String.to_integer(age_string)

            {:ok, %{time: time, lat: lat, long: long, speed: speed, heading: heading, source: source, age: age}}
        else
            {:error, :eshortline}
        end
    end

    @spec parse(String.t) :: [map]
    def parse(file_contents) do
        #Split file contents into lines (lineseps might have extra CR), parse each line, remove any error tuples, and return the second element of the remaining {:ok, result} tuples (ignoring any nil)
        file_contents |> String.split(~r/[\r\n]+/) |> Enum.map(&parse_line(&1)) |> Enum.reject(& elem(&1,0)==:error) |> Enum.map(&elem(&1, 1)) |> Enum.reject(& &1==nil)
    end

    @spec parse_file(String.t) :: map
    def parse_file(file_path) do
        {:ok, file} = File.open(file_path, [:read])
        read_lines(file, IO.read(file, :line), [])
    end

    @spec read_lines(File.io_device, :eof, map) :: map
    def read_lines(_file, :eof, data) do
        data
    end

    @spec read_lines(File.io_device, String.t, map) :: map
    def read_lines(file, this_line, data) do
        case parse_line(this_line) do
            {:ok, nil} -> read_lines(file, IO.read(file, :line), data)
            {:ok, parsed_line} -> read_lines(file, IO.read(file, :line), [parsed_line | data])
            {:error, :eshortline} -> data
        end
    end
end
