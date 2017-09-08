defmodule TrainLoc.Vehicles.Vehicles do

    def get(vehicles, vehicle_id) do
        Map.get(vehicles, vehicle_id)
    end

    def put(vehicles, vehicle_id, vehicle_data) do
        {:ok, Map.put(vehicles, vehicle_id, vehicle_data)}
    end
    def put(vehicles, {vehicle_id, vehicle_data}) do
        put(vehicles, vehicle_id, vehicle_data)
    end

    def update(vehicles, vehicle_id, vehicle_data) do
        vehicles = if Map.has_key?(vehicles, vehicle_id) do
            last_timestamp = vehicles |> Map.get(vehicle_id) |> Map.get(:timestamp)
            if vehicle_data |> Map.get(:timestamp) > last_timestamp do
                Map.put(vehicles, vehicle_id, vehicle_data)
            else
                vehicles
            end
        else
            Map.put(vehicles, vehicle_id, vehicle_data)
        end
        {:ok, vehicles}
    end
    def update(vehicles, {vehicle_id, vehicle_data}) do
        update(vehicles, vehicle_id, vehicle_data)
    end

    def delete(vehicles, vehicle_id) do
        {:ok, Map.delete(vehicles, vehicle_id)}
    end

    def find_duplicate_logons(vehicles) do
        same_workpiece = vehicles |> Map.values |> Enum.group_by(& &1.workpiece) |> Enum.reject(&match?({_,[_]}, &1))
        same_pattern = vehicles |> Map.values |> Enum.group_by(& &1.pattern) |> Enum.reject(&match?({_,[_]}, &1))
        {same_pattern, same_workpiece}
    end
end
