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

    @spec purge_old_vehicles(map, Timex.Duration.t) :: {:ok, map, [Vehicle.t]}
    def purge_old_vehicles(vehicles, duration \\ nil) do
        duration = if duration == nil, do: Timex.Duration.from_days(1), else: duration

        newest = vehicles |> Map.values |> Enum.map(& &1.timestamp) |> Enum.max
        vehicles_to_purge = vehicles |> Map.values |> Enum.split_with(& Timex.diff(newest, &1.timestamp, :duration) < duration) |> elem(1)
        vehicles = vehicles_to_purge |> Enum.reduce(vehicles, fn(x, acc) -> Map.delete(acc, x.vehicle_id) end)
        {:ok, vehicles, vehicles_to_purge}
    end

    @spec find_duplicate_logons(map) :: [Conflict.t]
    def find_duplicate_logons(vehicles) do
        same_trip = vehicles |> Map.values |> Enum.group_by(& &1.trip) |> Enum.reject(&reject_group?(&1)) |> Enum.map(&Conflict.from_tuple(&1, :trip))
        same_block = vehicles |> Map.values |> Enum.group_by(& &1.block) |> Enum.reject(&reject_group?(&1)) |> Enum.map(&Conflict.from_tuple(&1, :block))
        Enum.concat(same_trip, same_block)
    end

    @spec reject_group?({String.t, [Vehicle.t]}) :: boolean
    defp reject_group?(grouping) do
        match?({_,[_]}, grouping) or elem(grouping, 0) == "0" or elem(grouping, 0) == "9999"
    end
end
