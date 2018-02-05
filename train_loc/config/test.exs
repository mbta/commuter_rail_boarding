use Mix.Config

config :logger,
  backends: [:console]

config :logger, :console,
  level: :warn

# test-credentials.json comes from the goth repo
config :goth, json: File.read!("test/test-credentials.json")

config :trainloc, APIFetcher,
  connect_at_startup?: false

config :trainloc,
  # This is the timestamp from the end of the OneMinute integration test scenario, used to ensure
  # that the test messages aren't discarded as stale.
  time_baseline_fn: fn -> 1517253825 end,
  time_format: "{YYYY}-{0M}-{0D} {0h24}:{0m}:{0s} {Zname}"
