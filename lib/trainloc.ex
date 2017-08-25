defmodule TrainLoc do
    @moduledoc """
    Documentation for TrainLoc.
    """

    def process_file(file_name) do
        parse_result = Parser.parse_file(file_name)
        case parse_result do
            {:ok, records} -> check_duplicate_sign_ons(records, 0, [])
            {:error, reason} -> IO.puts("Couldn't read file: " <> reason)
        end
    end

    def check_duplicate_sign_ons(records, index, sign_ons) do
        current_record = Enum.at(records, index)
        unless Map.get(current_record, :workpiece) == "0" do
            this_vehicle_id = Map.get(current_record, :vehicle_id)
            this_workpiece = Map.get(current_record, :workpiece)
            current_sign_on = {this_vehicle_id, this_workpiece}
            vehicle_match = List.keyfind(sign_ons, this_vehicle_id, 0)
            workpiece_match = List.keyfind(sign_ons, this_workpiece, 1)
            sign_ons = if vehicle_match == nil do
                [current_sign_on | sign_ons]
            else
                sign_ons
            end
            case workpiece_match do
                {vehicle_id, workpiece} when vehicle_id != this_vehicle_id -> IO.puts(vehicle_id <> " and " <> this_vehicle_id <> " both signed into workpiece " <> workpiece)
                _ -> :ok
            end
        end
        check_duplicate_sign_ons(records, index + 1, sign_ons)
    end

    def hello do
        :world
    end
end
