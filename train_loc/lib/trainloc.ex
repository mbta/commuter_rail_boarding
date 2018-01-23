defmodule TrainLoc do
  @moduledoc """
  Core module for TrainLoc; it supervises the non-State GenServers, and other core
  persistence modules.
  """

  use Application

  require Logger

  @env Mix.env

  def env, do: @env

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(TrainLoc.Supervisor, []),
      worker(TrainLoc.Manager, [[
        name: TrainLoc.Manager
        ]]),
      worker(TrainLoc.Input.APIFetcher, [[
        name: TrainLoc.Input.APIFetcher,
        url: {TrainLoc.Utilities.FirebaseUrl, :url, []}
        ]]),
      worker(Logger.Backend.Logentries.Output.SslKeepOpen.Server, [])
    ]

    Logger.info(fn -> "Starting main TrainLoc supervisor..." end)
    opts = [strategy: :one_for_all, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
