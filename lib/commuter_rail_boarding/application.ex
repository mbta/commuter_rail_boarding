defmodule CommuterRailBoarding.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = env_children(System.get_env("MIX_ENV")) ++ [
      TripCache,
      RouteCache,

      {ServerSentEvent.Producer,
       name: ServerSentEvent.Producer,
       url: {FirebaseUrl, :url, []}},

      {BoardingStatus.ProducerConsumer,
       name: BoardingStatus.ProducerConsumer,
       subscribe_to: [ServerSentEvent.Producer]},

      {TripUpdates.ProducerConsumer,
       name: TripUpdates.ProducerConsumer,
       subscribe_to: [BoardingStatus.ProducerConsumer]},

      {Uploader.Consumer,
       name: Uploader.Consumer,
       subscribe_to: [TripUpdates.ProducerConsumer]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CommuterRailBoarding.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp env_children("prod") do
    [
      Logger.Backend.Logentries.Output.SslKeepOpen.Server
    ]
  end
  defp env_children(_) do
    []
  end
end
