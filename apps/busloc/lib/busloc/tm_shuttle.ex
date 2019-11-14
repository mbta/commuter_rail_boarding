defmodule Busloc.TmShuttle do
  import Busloc.Utilities.ConfigHelpers

  @moduledoc """
  Represents a TransitMaster shuttle login message.
  """
  defstruct [
    :vehicle_id,
    :operator_name,
    :operator_id,
    :block,
    :run,
    :route
  ]

  @type t :: %__MODULE__{
          vehicle_id: String.t(),
          operator_name: String.t(),
          operator_id: String.t(),
          block: String.t(),
          run: String.t(),
          route: String.t()
        }

  defdelegate log_line(shuttle), to: Busloc.LogHelper, as: :log_struct

  @run_to_route config(TmShuttle, :run_to_route)
  @run_prefix_to_route config(TmShuttle, :run_prefix_to_route)

  # Check if the run has an exact match in full_runs.
  # If not, look for a partial match in run_prefixes.
  defp lookup_shuttle_route(run) do
    if route = Map.get(@run_to_route, run) do
      route
    else
      Enum.find_value(@run_prefix_to_route, fn {prefix, route} ->
        if String.starts_with?(run, prefix) do
          route
        end
      end)
    end
  end

  @spec from_map(map) :: [t()]
  def from_map(%{
        "vehicle_id" => vehicle_id,
        "block_id" => block_id,
        "operator_name" => operator_name,
        "operator_id" => operator_id,
        "run_id" => run_id
      }) do
    [
      %__MODULE__{
        vehicle_id: vehicle_id,
        operator_name: operator_name,
        operator_id: operator_id,
        block: block_id,
        run: run_id,
        route: lookup_shuttle_route(run_id)
      }
    ]
  end

  def from_map(_), do: []
end
