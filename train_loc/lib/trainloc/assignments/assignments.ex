defmodule TrainLoc.Assignments.Assignments do
    @moduledoc """
    Module for performing assignment-related functions for TrainLoc.Assignments.State
    """

    alias TrainLoc.Assignments.Assignment
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Utilities.Time

    @type assignments :: MapSet.t(Assignment.t)

    @log_dir Path.expand("~/log")

    @spec add(assignments, Vehicle.t) :: assignments
    def add(assigns, vehicle) do
        if Vehicle.active_vehicle?(vehicle) do
            assign = Assignment.from_vehicle(vehicle)
            MapSet.put(assigns, assign)
        else
            assigns
        end
    end

    @spec group_by_block_vehicle(assignments) :: map
    def group_by_block_vehicle(assigns) do
        Enum.reduce(assigns, %{}, &reduce_by_block_vehicle/2)
    end

    @spec group_by_vehicle_block(assignments) :: map
    def group_by_vehicle_block(assigns) do
        Enum.reduce(assigns, %{}, &reduce_by_vehicle_block/2)
    end

    @spec group_by_block(assignments) :: map
    def group_by_block(assigns) do
        Enum.reduce(assigns, %{}, &reduce_by_block/2)
    end

    @spec group_by_vehicle(assignments) :: map
    def group_by_vehicle(assigns) do
        Enum.reduce(assigns, %{}, &reduce_by_vehicle/2)
    end

    @spec write_state(assignments) :: :ok
    def write_state(state) do
        if not File.exists?(@log_dir), do: File.mkdir!(@log_dir)
        file_name = "assigns_wk_of_" <> Time.format_date(Time.first_day_of_week()) <> ".txt"
        file_loc = Path.join(@log_dir, file_name)

        file = File.open!(file_loc, [:append, :utf8])
        Enum.each(state, &IO.puts(file, Assignment.to_csv(&1)))
        File.close(file)
    end

    @spec reduce_by_block_vehicle(Assignment.t, map) :: map
    defp reduce_by_block_vehicle(next, grouping) do
        key = {next.service_date, next.block}
        update_in(grouping, [Access.key(key, %{}), Access.key(next.vehicle_id, [])], &update_trip_list(&1, next.trip))
    end

    @spec reduce_by_vehicle_block(Assignment.t, map) :: map
    defp reduce_by_vehicle_block(next, grouping) do
        key = {next.service_date, next.vehicle_id}
        update_in(grouping, [Access.key(key, %{}), Access.key(next.block, [])], &update_trip_list(&1, next.trip))
    end

    @spec reduce_by_block(Assignment.t, map) :: map
    defp reduce_by_block(next, grouping) do
        key = {next.service_date, next.block}
        update_in(grouping, [Access.key(key, [])], &update_trip_list(&1, next.trip))
    end

    @spec reduce_by_vehicle(Assignment.t, map) :: map
    defp reduce_by_vehicle(next, grouping) do
        key = {next.service_date, next.vehicle_id}
        update_in(grouping, [Access.key(key, [])], &update_trip_list(&1, next.trip))
    end

    @spec update_trip_list([String.t], String.t) :: [String.t]
    defp update_trip_list(trip_list, trip) do
        if Enum.member?(trip_list, trip), do: trip_list, else: trip_list ++ [trip]
    end
end
