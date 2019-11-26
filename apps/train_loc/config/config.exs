# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :train_loc, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:train_loc, :key)
#

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: String.to_existing_atom(System.get_env("LOG_LEVEL") || "debug")

config :goth, json: {:system, "CREDENTIALS_JSON"}

config :train_loc, APIFetcher, connect_at_startup?: true

config :train_loc,
  time_zone: "America/New_York",
  time_baseline_fn: {TrainLoc.Utilities.Time, :unix_now},
  excluded_vehicles: [1509, 1505, 1520],
  firebase_url: {:system, "FIREBASE_URL"},
  s3_api: TrainLoc.S3.InMemory

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env()}.exs"
