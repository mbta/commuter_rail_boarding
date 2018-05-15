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
          {Busloc.State, name: :eyeride_state},
          {Busloc.Fetcher.TmFetcher, url: config(TmFetcher, :url)},
          {Busloc.Fetcher.SamsaraFetcher, url: config(SamsaraFetcher, :url)},
          {Busloc.Fetcher.EyerideFetcher,
           host: config(EyerideFetcher, :host),
           email: config(EyerideFetcher, :email),
           password: config(EyerideFetcher, :password),
           state: :eyeride_state},
          {Busloc.Publisher, states: [Busloc.State, :eyeride_state]}
        ]
      else
        []
      end

    Supervisor.start_link(children, strategy: :rest_for_one)
  end
end
