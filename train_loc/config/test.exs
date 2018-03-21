use Mix.Config

config :logger, backends: [:console]

config :logger, :console, level: :warn

# test-credentials.json comes from the goth repo
config :goth, json: File.read!("test/test-credentials.json")

config :trainloc, APIFetcher, connect_at_startup?: false

config :trainloc,
  time_baseline_fn: {TrainLoc.IntegrationTest.TimeHelper, :test_time},
  time_format: "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s} {Zname}"
