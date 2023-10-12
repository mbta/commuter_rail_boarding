defmodule TrainLoc do
  @moduledoc """
  Starts the top level supervisor for the application.
  """

  use Application

  require Logger

  @env Mix.env()

  def env, do: @env

  def start(_type, _args) do
    children = [
      TrainLoc.Supervisor
      | start_children(Application.get_env(:train_loc, APIFetcher)[:connect_at_startup?])
    ]

    _ = Logger.info(fn -> "Starting main TrainLoc supervisor..." end)
    opts = [strategy: :one_for_all, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  defp start_children(true) do
    [
      {ServerSentEventStage,
       name: TrainLoc.Input.APIFetcher, url: {TrainLoc.Utilities.FirebaseUrl, :url, []}},
      {TrainLoc.Manager, name: TrainLoc.Manager, subscribe_to: TrainLoc.Input.APIFetcher}
    ]
  end

  defp start_children(false) do
    [
      {TrainLoc.Manager, name: TrainLoc.Manager}
    ]
  end
end
