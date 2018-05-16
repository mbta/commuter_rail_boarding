defmodule Busloc do
  @moduledoc """
  Documentation for Busloc.
  """
  use Application
  import Busloc.Utilities.ConfigHelpers

  def start(_type, _args) do
    children =
      if config(:start?) do
        [
          Busloc.Supervisor.Eyeride,
          Busloc.Supervisor.Transitmaster,
          {Busloc.Publisher, states: [:transitmaster_state, :eyeride_state]}
        ]
      else
        []
      end

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
