use Mix.Config

config :ehmon, :report_mf, {:ehmon, :info_report}

config :logger,
  backends: [{Logger.Backend.Logentries, :logentries}, :console]

config :logger, :logentries,
  connector: Logger.Backend.Logentries.Output.SslKeepOpen,
  host: 'data.logentries.com',
  port: 443,
  token: {:system, "LOGENTRIES_TOKEN"},
  format: "$dateT$time [$level]$levelpad node=$node $metadata$message\n",
  metadata: [:request_id]
