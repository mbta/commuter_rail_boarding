defmodule Busloc.Supervisor.Saucon do
  @moduledoc """
  Supervisor for the Saucon state and fetcher.
  """
  import Busloc.Utilities.ConfigHelpers

  def start_link do
    children = [
      {Busloc.State, name: :saucon_state},
      {Busloc.Fetcher.SauconFetcher,
       url: config(SauconFetcher, :url)
      }
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      type: :supervisor,
      start: {__MODULE__, :start_link, []}
    }
  end
end
