defmodule TrainLoc.Input.Parser do
    @moduledoc """
    Parser for PTIS data
    """
    alias TrainLoc.Vehicles.Vehicle
    import :binary, only: [copy: 1]

    @regex ~r/
        (?<timestamp>[01]\d-[0-3]\d-[0-9]{4}\s[0-2]\d:[0-5]\d:[0-5]\d\s[AP]M)[\t]
        Vehicle\sID:(?<vehicle_id>\d+)
        \s-\s
        (?<type>\w+)
        \[
            Operator:(?<operator>\d+),\s
            Workpiece:(?<workpiece>\d+),\s
            Pattern:(?<pattern>\d+),\s
            GPS:>RPV
                (?<time>\d{5})
                (?<lat>[+-]\d{7})
                (?<long>[+-]\d{8})
                (?<speed>\d{3})
                (?<heading>\d{3})
                (?<source>\d)
                (?<age>\d)
            <
        \]
    /x

    @spec parse_line(String.t) :: map | nil
    def parse_line(line) do
        case Regex.named_captures(@regex, line) do
            map when is_map(map) -> Map.new(map, fn {k,v} -> {copy(k), copy(v)} end)
            _ -> nil
        end
    end

    @spec parse(String.t) :: [Vehicle.t]
    def parse(file_contents) do
        #Split file contents into lines (lineseps might have extra CR), parse each line, and remove any nil results (lines that didn't match the regex)
        file_contents |> String.split(~r/[\r\n]+/) |> Enum.map(&parse_line(&1)) |> Enum.reject(& &1==nil) |> Enum.map(&Vehicle.from_map(&1))
    end
end
