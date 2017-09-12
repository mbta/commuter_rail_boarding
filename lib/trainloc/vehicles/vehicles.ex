defmodule TrainLoc.Vehicles.Vehicles do
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Conflicts.Conflict

    @spec get(map, Vehicle.t) :: Vehicle.t | nil
    def get(vehicles, vehicle_id) do
        Map.get(vehicles, vehicle_id)
    end

    @spec put(map, Vehicle.t) :: {:ok, map}
    def put(vehicles, vehicle) do
        {:ok, Map.put(vehicles, vehicle.vehicle_id, vehicle)}
    end

    @spec update(map, Vehicle.t) :: {:ok, map}
    def update(vehicles, vehicle) do
        vehicle_id = vehicle.vehicle_id
        vehicles = if Map.has_key?(vehicles, vehicle_id) do
            existing_vehicle = Map.get(vehicles, vehicle_id)
            existing_timestamp = existing_vehicle.timestamp
            if vehicle.timestamp > existing_timestamp do
                Map.put(vehicles, vehicle_id, vehicle)
            else
                vehicles
            end
        else
            Map.put(vehicles, vehicle_id, vehicle)
        end
        {:ok, vehicles}
    end

    @spec delete(map, String.t) :: {:ok, map}
    def delete(vehicles, vehicle_id) do
        {:ok, Map.delete(vehicles, vehicle_id)}
    end

    @spec find_duplicate_logons(map) :: [Conflict.t]
    def find_duplicate_logons(vehicles) do
        same_pattern = vehicles |> Map.values |> Enum.group_by(& &1.pattern) |> Enum.reject(&match?({_,[_]}, &1)) |> Enum.map(&Conflict.from_tuple(&1, :pattern))
        same_workpiece = vehicles |> Map.values |> Enum.group_by(& &1.workpiece) |> Enum.reject(&match?({_,[_]}, &1)) |> Enum.map(&Conflict.from_tuple(&1, :workpiece))
        Enum.concat(same_pattern, same_workpiece)
    end
end
