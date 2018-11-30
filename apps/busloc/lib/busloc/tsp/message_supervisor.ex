defmodule Busloc.Tsp.MessageSupervisor do
  use DynamicSupervisor
  require Logger

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(socket) do
    spec = {Busloc.Tsp.Message, socket}
    {:ok, _pid} = DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
