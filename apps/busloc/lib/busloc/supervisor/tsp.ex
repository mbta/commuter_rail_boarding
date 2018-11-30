defmodule Busloc.Supervisor.Tsp do
  @moduledoc """
  Supervisor for the TSP socket proxy (listens from TransitMaster, http to IBI TSP software on opstech3)
  """

  def start_link do
    children = [
      {Busloc.Tsp.Listener, 9005},
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
