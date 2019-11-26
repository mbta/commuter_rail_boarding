use Mix.Config

config :commuter_rail_boarding,
  uploader: Uploader.S3

config :commuter_rail_boarding, Uploader.S3,
  requestor: ExAws,
  bucket: {:system, "S3_BUCKET"}

# Configures Elixir's Logger
config :sasl, errlog_type: :error

config :logger,
  truncate: :infinity,
  handle_sasl_reports: true,
  level: :debug,
  backends: [:console]

config :ehmon, :report_mf, {:ehmon, :info_report}

config :sasl, errlog_type: :error

config :train_loc,
  s3_api: TrainLoc.S3.HTTPClient,
  s3_bucket: {:system, "S3_BUCKET"}
