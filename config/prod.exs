import Config

config :commuter_rail_boarding,
  uploader: Uploader.S3

config :commuter_rail_boarding, Uploader.S3,
  requestor: ExAws,
  bucket: {:system, "S3_BUCKET"}

config :logger,
  truncate: :infinity,
  level: :debug,
  backends: [:console, Sentry.LoggerBackend]

config :ehmon, :report_mf, {:ehmon, :info_report}

config :train_loc,
  s3_api: TrainLoc.S3.HTTPClient,
  s3_bucket: {:system, "S3_BUCKET"}
