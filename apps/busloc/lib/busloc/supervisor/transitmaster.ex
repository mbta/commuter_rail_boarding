defmodule Busloc.Supervisor.Transitmaster do
  @moduledoc """
  Supervisor for the Transitmaster state and fetcher.

  Also includes the Samsara fetcher, since we merge that data with the
  Transitmaster data.
  """
  import Busloc.Utilities.ConfigHelpers

  def start_link do
    children = [
      {Busloc.State, name: :transitmaster_state},
      {Busloc.Fetcher.TmFetcher, url: config(TmFetcher, :url)},
      {Busloc.Fetcher.SamsaraFetcher, url: config(SamsaraFetcher, :url)}
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
