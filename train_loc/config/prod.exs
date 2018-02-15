use Mix.Config

config :ehmon, :report_mf, {:ehmon, :info_report}

config :sasl,
  errlog_type: :error

config :logger,
  truncate: :infinity,
  handle_sasl_reports: true,
  backends: [:console]

config :trainloc,
  s3_api: TrainLoc.S3.HTTPClient,
  s3_bucket: {:system, "S3_BUCKET"}
