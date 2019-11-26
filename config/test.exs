use Mix.Config

config :logger, backends: [:console], level: :debug

config :logger, :console, level: :warn

# test-credentials.json comes from the goth repo
config :goth, json: File.read!("test/test-credentials.json")

config :commuter_rail_boarding,
  firebase_url: "http://httpbin.org?numbytes=1024&duration=2&code=200",
  uploader: Uploader.Mock,
  start_children?: false

config :train_loc, APIFetcher, connect_at_startup?: false

config :train_loc,
  firebase_url: "http://httpbin.org?numbytes=1024&duration=2&code=200",
  time_baseline_fn: {TrainLoc.IntegrationTest.TimeHelper, :test_time},
  time_format: "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s} {Zname}"
