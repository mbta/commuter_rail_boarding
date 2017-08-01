# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# test-credentials.json comes from the goth repo
config :goth,
  json: File.read!("test/test-credentials.json")

#     import_config "#{Mix.env}.exs"
