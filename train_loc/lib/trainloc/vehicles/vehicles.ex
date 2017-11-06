defmodule TrainLoc.Vehicles.Vehicles do
    @moduledoc """
    Module for performing vehicle-related functions for TrainLoc.Vehicles.State
    """

    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Conflicts.Conflict
    alias TrainLoc.Utilities.Time

    require Logger

    @spec get(map, Vehicle.t) :: Vehicle.t | nil
    def get(vehicles, vehicle_id) do
        vehicles[vehicle_id]
    end

    @spec put(map, Vehicle.t) :: {:ok, map}
    def put(vehicles, vehicle) do
        {:ok, Map.put(vehicles, vehicle.vehicle_id, vehicle)}
    end

    @spec update(map, Vehicle.t) :: {:ok, map}
    def update(all_vehicles, %Vehicle{vehicle_id: vehicle_id} = new_vehicle) do
        all_vehicles
            |> Map.get(vehicle_id)
            |> do_update(all_vehicles, new_vehicle)
    end

    @spec delete(map, String.t) :: {:ok, map}
    def delete(vehicles, vehicle_id) do
        {:ok, Map.delete(vehicles, vehicle_id)}
    end

    @spec purge_old_vehicles(map, Timex.Duration.t) :: {:ok, map, [Vehicle.t]}
    def purge_old_vehicles(vehicles, duration \\ nil) do
        duration = if duration == nil, do: Timex.Duration.from_days(1), else: duration
        if Enum.empty?(vehicles) do
            {:ok, vehicles, []}
        else
            newest =
                vehicles
                |> Map.values()
                |> Enum.map(& &1.timestamp)
                |> Enum.max_by(&Timex.to_unix/1)

            vehicles_to_purge =
                vehicles
                |> Map.values()
                |> Enum.split_with(& Timex.diff(newest, &1.timestamp, :duration) < duration)
                |> elem(1)

            vehicles = Enum.reduce(vehicles_to_purge, vehicles, fn(x, acc) -> Map.delete(acc, x.vehicle_id) end)

            {:ok, vehicles, vehicles_to_purge}
        end
    end

    @spec find_duplicate_logons(map) :: [Conflict.t]
    def find_duplicate_logons(vehicles) do
        same_trip =
            vehicles
            |> Map.values()
            |> Enum.group_by(& &1.trip)
            |> Enum.reject(&reject_group?/1)
            |> Enum.map(&Conflict.from_tuple(&1, :trip))

        same_block =
            vehicles
            |> Map.values()
            |> Enum.group_by(& &1.block)
            |> Enum.reject(&reject_group?/1)
            |> Enum.map(&Conflict.from_tuple(&1, :block))

        Enum.concat(same_trip, same_block)
    end

    @spec reject_group?({String.t, [Vehicle.t]}) :: boolean
    defp reject_group?({_,[_]}), do: true
    defp reject_group?({"0", _}), do: true
    defp reject_group?({"9999", _}), do: true
    defp reject_group?({_,_}), do: false

    defp do_update(nil, all_vehicles, new_vehicle) do
        {:ok, Map.put(all_vehicles, new_vehicle.vehicle_id, new_vehicle)}
    end
    defp do_update(old_vehicle, all_vehicles, new_vehicle) do
        new_vehicle.timestamp
        |> Timex.after?(old_vehicle.timestamp)
        |> do_replace(old_vehicle, new_vehicle, all_vehicles)
    end

    defp do_replace(true, old_vehicle, %Vehicle{vehicle_id: vehicle_id} = new_vehicle, all_vehicles) do
        log_if_changed_assign(old_vehicle, new_vehicle)
        {:ok, Map.put(all_vehicles, vehicle_id, new_vehicle)}
    end
    defp do_replace(false, _old_vehicle, _new_vehicle, all_vehicles) do
        {:ok, all_vehicles}
    end

    defp log_if_changed_assign(old, new) do
        if old.block != new.block do
            Logger.debug("BLOCK CHANGE " <> Time.format_datetime(new.timestamp) <> " - " <> new.vehicle_id <> ": " <> old.block <> "->" <> new.block)
        end
        if old.trip != new.trip do
            Logger.debug("TRIP CHANGE " <> Time.format_datetime(new.timestamp) <> " - " <> new.vehicle_id <> ": " <> old.trip <> "->" <> new.trip)
        end
    end
end
