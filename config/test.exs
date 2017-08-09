use Mix.Config

config :commuter_rail_boarding,
  firebase_url: "http://httpbin.org?numbytes=1024&duration=2&code=200",
  uploader: Uploader.Mock

# test-credentials.json comes from the goth repo
config :goth, json: File.read!("test/test-credentials.json")

# increase default assert_receive timeout
config :ex_unit, assert_receive_timeout: 1_000

config :logger, level: :warn
