import Config

# Mapping of `gtfs_stop_name` values to stop IDs. Note these are expected to be valid *both* on
# their own, and when a track number is appended, if the boarding status has a track assignment
# (see `TripUpdates.platform_id_map/2`).
#
# When the value is a map, this maps specific track numbers to stop IDs. The key `""` must be
# present to account for boarding statuses with no track assignment. Only the `""` stop ID needs
# to be valid on its own.
config :commuter_rail_boarding,
  stop_ids: %{
    "South Station" => "NEC-2287",
    "North Station" => "BNT-0000",
    "Back Bay" => %{
      "" => "NEC-2276",
      "1" => "NEC-2276",
      "2" => "NEC-2276",
      "3" => "NEC-2276",
      "5" => "WML-0012",
      "7" => "WML-0012"
    },
    "Ruggles" => "NEC-2265"
  }

config :commuter_rail_boarding,
  firebase_url: {:system, "CRB_FIREBASE_URL"},
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

config :commuter_rail_boarding, Uploader.S3, bucket: "console"

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

config :shared, new_bucket: "new_bucket"

import_config "#{Mix.env()}.exs"
