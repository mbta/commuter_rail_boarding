# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :commuter_rail_boarding,
  firebase_url: "https://keolis-api-production.firebaseio.com/12001_departureData_nodejs.json",
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
    "" => :on_time,
    "AA" => :all_aboard,
    "AR" => :arrived,
    "ARVG" => :arriving,
    "BL" => :not_stopping_here, # :blue_line,
    "BS" => :bus_substitution,
    "CX" => :cancelled,
    "DL" => :delayed,
    "DP" => :departed,
    "GL" => :not_stopping_here, # :green_line,
    "HD" => :info_to_follow, # :hold,
    "LT" => :late,
    "NB" => :now_boarding,
    "ON" => :on_time,
    "OL" => :not_stopping_here, # :orange_line,
    "PR" => :info_to_follow, # :priority,
    "RL" => :not_stopping_here, # :red_line,
    "SA" => :see_agent,
    "SL" => :not_stopping_here, # :silver_line,
    "SUB" => :not_stopping_here # :subway
  },
  uploader: Uploader.Console,
  v3_api_key: System.get_env("V3_API_KEY") # also overriden by CommuterRailBoarding.Application

config :goth,
  json: {:system, "GCS_CREDENTIAL_JSON"}

import_config "#{Mix.env}.exs"
