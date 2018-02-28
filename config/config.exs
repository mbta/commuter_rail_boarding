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
    "" => :on_time,
    "AA" => :all_aboard,
    "AR" => :arrived,
    "ARVG" => :arriving,
    # :blue_line,
    "BL" => :not_stopping_here,
    "BS" => :bus_substitution,
    "CX" => :cancelled,
    "DL" => :delayed,
    "DP" => :departed,
    # :green_line,
    "GL" => :not_stopping_here,
    # :hold,
    "HD" => :info_to_follow,
    "LT" => :late,
    "NB" => :now_boarding,
    "ON" => :on_time,
    # :orange_line,
    "OL" => :not_stopping_here,
    # :priority,
    "PR" => :info_to_follow,
    # :red_line,
    "RL" => :not_stopping_here,
    "SA" => :see_agent,
    # :silver_line,
    "SL" => :not_stopping_here,
    # :subway
    "SUB" => :not_stopping_here
  },
  uploader: Uploader.Console,
  # also overriden by CommuterRailBoarding.Application
  v3_api_key: System.get_env("V3_API_KEY")

config :goth, json: {:system, "GCS_CREDENTIAL_JSON"}

import_config "#{Mix.env()}.exs"
