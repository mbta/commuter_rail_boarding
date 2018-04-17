use Mix.Config

config :logger, backends: [:console]

config :logger, :console, level: :warn

# test-credentials.json comes from the goth repo
prefix =
  if Mix.Project.umbrella?() do
    "apps/train_loc"
  else
    "."
  end

config :goth, json: File.read!("#{prefix}/test/test-credentials.json")

config :train_loc, APIFetcher, connect_at_startup?: false

config :train_loc,
  time_baseline_fn: {TrainLoc.IntegrationTest.TimeHelper, :test_time},
  time_format: "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s} {Zname}"
