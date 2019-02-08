defmodule Busloc.Supervisor.Tsp do
  @moduledoc """
  Supervisor for the TSP socket proxy (listens from TransitMaster, http to IBI TSP software on opstech3)
  """
  import Busloc.Utilities.ConfigHelpers

  def start_link do
    # Use the non-production port as the default if the environment variable is not set (e.g. local testing)
    tsp_port = config(Tsp, :socket_port) || "9006"

    children = [
      {Busloc.Tsp.Listener, String.to_integer(tsp_port)},
      {Busloc.Tsp.MessageSupervisor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_all)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      type: :supervisor,
      start: {__MODULE__, :start_link, []}
    }
  end
end
