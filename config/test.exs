use Mix.Config

config :commuter_rail_boarding,
  uploader: Uploader.Mock

# test-credentials.json comes from the goth repo
config :goth, json: File.read!("test/test-credentials.json")
