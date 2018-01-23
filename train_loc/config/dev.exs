use Mix.Config

config :logger,
  backends: [:console]

config :logger, :console,
  level: :debug

config :trainloc, TrainLoc.Utilities.ConflictMailer,
  adapter: Bamboo.LocalAdapter

config :trainloc,
  email_queue_delay: 5000
