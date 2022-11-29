import Config

config :logger, backends: [:console], level: :debug

config :logger, :console, level: :warn

# test-credentials.json comes from the goth repo:
# https://github.com/peburrows/goth/blob/be68c4b034dd2700b9ddbc02488b45f9ce7e56ba/config/test-credentials.json
config :goth, json: File.read!("test/test-credentials.json")

config :commuter_rail_boarding,
  firebase_url: "http://httpbin.org?numbytes=1024&duration=2&code=200",
  uploader: Uploader.Mock,
  start_children?: false

config :train_loc, APIFetcher, connect_at_startup?: false

config :train_loc,
  firebase_url: "http://httpbin.org?numbytes=1024&duration=2&code=200",
  time_baseline_fn: {TrainLoc.IntegrationTest.TimeHelper, :test_time}
