defmodule Parser do
    @moduledoc """
    Parser for PTIS data
    """

    def parse_line(line) do
        split_line = String.split(line, " - ")
        line_prefix = Enum.at(split_line,0)
        if String.length(line_prefix) == 38 do
            split_prefix = String.split_at(line_prefix, 22)
            timestamp = case Timex.parse(elem(split_prefix, 0), "{0M}-{0D}-{YYYY} {0h12}:{0m}:{0s} {AM}") do
                {:ok, result} -> result
                {:error, reason} -> {:error, reason}
            end
            if timestamp == {:error, :eshortline} do
                {:error, :eshortline}
            else
                vehicle_id = elem(String.split_at(elem(split_prefix, 1), 12), 1)
                case parse_msg_body(Enum.at(split_line, 1)) do
                    {:ok, parsed_body} -> {:ok, Map.merge(%{timestamp: timestamp, vehicle_id: vehicle_id}, parsed_body)}
                    {:error, reason} -> {:error, reason}
                end
            end
        else
            {:error, :eshortline}
        end
    end

    def parse_msg_body(data) do
        [type, body] = String.split(data, "[")
        data_map = %{type: type}
        if Map.get(data_map, :type) == "Location" do
            split_body = String.split(elem(String.split_at(body, -1), 0), ", ")
            if length(split_body) == 4 do
                [operator_clause, workpiece_clause, pattern_clause, gps_clause] = split_body
                gps_parse_result = parse_gps(Enum.at(String.split(gps_clause, ":"), 1))
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
            {:ok, data_map}
        end
    end

    def split_by_colon(input) do
        Enum.at(String.split(input, ":"), 1)
    end

    def parse_gps(gps_data) do
        if String.starts_with?(gps_data, ">RPV") and String.length(gps_data) >= 35 do
            {_, rest} = String.split_at(gps_data, 4)
            {time, rest} = String.split_at(rest, 5)
            {lat, rest} = String.split_at(rest, 8)
            {long, rest} = String.split_at(rest, 9)
            {speed, rest} = String.split_at(rest, 3)
            {heading, rest} = String.split_at(rest, 3)
            {source, rest} = String.split_at(rest, 1)
            {age, _} = String.split_at(rest, 1)
            {:ok, %{time: time, lat: lat, long: long, speed: speed, heading: heading, source: source, age: age}}
        else
            {:error, :eshortline}
        end
    end

    def parse_file(file_path) do
        {:ok, file} = File.open(file_path, [:read])
        read_lines(file, IO.read(file, :line), [])
    end

    def read_lines(file, :eof, data) do
        data
    end

    def read_lines(file, this_line, data) do
        case parse_line(this_line) do
            {:ok, parsed_line} -> read_lines(file, IO.read(file, :line), [parsed_line | data])
            {:error, :eshortline} -> data
        end
    end
end
