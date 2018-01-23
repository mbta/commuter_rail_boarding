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
#     config :trainloc, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:trainloc, :key)
#

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: String.to_existing_atom(System.get_env("LOG_LEVEL") || "info")

config :goth,
  json: {:system, "CREDENTIALS_JSON"}

config :trainloc, TrainLoc.Utilities.ConflictMailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtprelay.mbta.com",
  port: 25,
  username: Application.get_env(:trainloc, :mailer_username),
  password: Application.get_env(:trainloc, :mailer_password),
  tls: :never,
  ssl: false,
  retries: 1

config :trainloc,
  time_zone: "America/New_York",
  firebase_url: {:system, "FIREBASE_URL"},
  mailer_username: {:system, "MAILER_USERNAME"},
  mailer_password: {:system, "MAILER_PASSWORD"},
  email_to: {:system, "MAILER_TO"},
  email_from: {"Developer", "developer@mbta.com"},
  email_queue_delay: 5*60*1000

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
