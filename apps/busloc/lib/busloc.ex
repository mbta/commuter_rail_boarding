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
          {Busloc.State, name: Busloc.State},
          {Busloc.Fetcher.TmFetcher, url: config(TmFetcher, :url)},
          {Busloc.Fetcher.SamsaraFetcher, url: config(SamsaraFetcher, :url)},
          {Busloc.Publisher, []}
        ]
      else
        []
      end

    Supervisor.start_link(children, strategy: :rest_for_one)
  end
end
