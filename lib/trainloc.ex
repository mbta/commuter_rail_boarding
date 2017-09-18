defmodule TrainLoc do
    @moduledoc """
    Documentation for TrainLoc.
    """
use Application
require Logger

    @env Mix.env
    def env, do: @env

    def start(_type, _args) do
        import Supervisor.Spec, warn: false

        children = [
            supervisor(TrainLoc.Supervisor, []),
            worker(TrainLoc.Manager, [[name: TrainLoc.Manager]]),
            worker(TrainLoc.Input.FTP, [[name: TrainLoc.Input.FTP]]),
            worker(Logger.Backend.Logentries.Output.SslKeepOpen.Server, [])
        ]

        Logger.info("Starting main TrainLoc supervisor...")
        opts = [strategy: :one_for_all, name: __MODULE__]
        Supervisor.start_link(children, opts)
    end
end
