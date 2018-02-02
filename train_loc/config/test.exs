use Mix.Config

config :logger,
  backends: [:console]

config :logger, :console,
  level: :warn

# test-credentials.json comes from the goth repo
config :goth, json: File.read!("test/test-credentials.json")
