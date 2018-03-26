defmodule Busloc do
  @moduledoc """
  Documentation for Busloc.
  """
  use Application
  import Busloc.Utilities.ConfigHelpers

  def start(_type, _args) do
    children = [
      {Busloc.TmFetcher, url: config(TmFetcher, :url)}
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
