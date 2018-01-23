use Mix.Config

config :logger,
  backends: [:console]

config :logger, :console,
  level: :warn

# test-credentials.json comes from the goth repo
config :goth, json: File.read!("test/test-credentials.json")

config :bamboo,
  refute_timeout: 10

config :trainloc, TrainLoc.Utilities.ConflictMailer,
  adapter: Bamboo.TestAdapter

config :trainloc,
  email_queue_delay: 100
