# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :commuter_rail_boarding,
  firebase_url:
    "https://keolis-api-production.firebaseio.com/12001_departureData_nodejs.json",
  stop_ids: %{
    "Boston" => "South Station",
    "Boston North Station" => "North Station"
  },
  headsigns: %{
    "Forge Park/495" => "Forge Park / 495",
    "Anderson/Woburn" => "Anderson / Woburn",
    "Worcester" => "Worcester / Union Station",
    "Littleton/Rte 495" => "Littleton / Rte 495",
    "Middleborough/Lakeville" => "Middleboro/Lakeville"
  },
  statuses: %{
    "" => "On time",
    "AA" => "All aboard",
    "AR" => "Arrived",
    "ARVG" => "Arriving",
    # "Blue Line",
    "BL" => "Not stopping here",
    "BS" => "Bus substitution",
    "CX" => "Cancelled",
    "DL" => "Delayed",
    "DP" => "Departed",
    # "Green line",
    "GL" => "Not stopping here",
    # "Hold",
    "HD" => "Info to follow",
    "LT" => "Late",
    "NB" => "Now boarding",
    "ON" => "On Time",
    # "Orange line",
    "OL" => "Not stopping here",
    # "Priority",
    "PR" => "Info to follow",
    # "Red line",
    "RL" => "Not stopping here",
    "SA" => "See agent",
    # "Silver line",
    "SL" => "Not stopping here",
    # "Subway"
    "SUB" => "Not stopping here"
  },
  uploader: Uploader.Console,
  # also overriden by CommuterRailBoarding.Application
  v3_api_key: System.get_env("V3_API_KEY")

config :goth, json: {:system, "GCS_CREDENTIAL_JSON"}

import_config "#{Mix.env()}.exs"
