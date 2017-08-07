# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :commuter_rail_boarding,
  firebase_url: "https://keolis-api-production.firebaseio.com/departureData.json",
  stop_ids: %{
    "Boston" => "South Station",
    "Boston North Station" => "North Station",
    "Back Bay" => "Back Bay"
  },
  uploader: Uploader.Console

config :goth,
  json: {:system, "GCS_CREDENTIAL_JSON"}

import_config "#{Mix.env}.exs"
