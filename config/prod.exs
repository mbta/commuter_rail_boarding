use Mix.Config

config :commuter_rail_boarding,
  firebase_url: {:system, "FIREBASE_URL"},
  uploader: Uploader.S3

config :commuter_rail_boarding, Uploader.S3,
  requestor: ExAws,
  bucket: {:system, "S3_BUCKET"}

# Configures Elixir's Logger
config :sasl,
  errlog_type: :error

config :logger,
  truncate: :infinity,
  handle_sasl_reports: true,
  level: :debug,
  backends: [{Logger.Backend.Logentries, :logentries}, :console]

config :logger, :logentries,
  connector: Logger.Backend.Logentries.Output.SslKeepOpen,
  host: 'data.logentries.com',
  port: 443,
  token: "${LOGENTRIES_TOKEN}",
  format: "$dateT$time [$level]$levelpad $metadata$message\n"

config :ehmon, :report_mf, {:ehmon, :info_report}
