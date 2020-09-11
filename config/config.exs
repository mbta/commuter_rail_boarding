use Mix.Config

config :commuter_rail_boarding,
  firebase_url: {:system, "CRB_FIREBASE_URL"},
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
  v3_api_key: System.get_env("V3_API_KEY"),
  v3_api_url: System.get_env("V3_API_URL"),
  start_children?: true

config :goth, json: {:system, "GCS_CREDENTIAL_JSON"}

config :logger,
  truncate: :infinity

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id],
  level: String.to_existing_atom(System.get_env("LOG_LEVEL") || "debug")

config :train_loc, APIFetcher, connect_at_startup?: true

config :train_loc,
  time_zone: "America/New_York",
  time_baseline_fn: {TrainLoc.Utilities.Time, :unix_now},
  excluded_vehicles: [1509, 1505, 1520],
  firebase_url: {:system, "TRAIN_LOC_FIREBASE_URL"},
  s3_api: TrainLoc.S3.InMemory

config :ex_aws,
  json_codec: Jason

import_config "#{Mix.env()}.exs"
