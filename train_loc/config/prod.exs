use Mix.Config

config :ehmon, :report_mf, {:ehmon, :info_report}

config :logger,
  backends: [{Logger.Backend.Splunk, :splunk}, :console]

config :logger, :splunk,
  connector: Logger.Backend.Splunk.Output.Http,
  host: 'https://http-inputs-mbta.splunkcloud.com/services/collector/event',
  token: {:system, "SPLUNK_TOKEN"},
  level: :debug,
  format: "$dateT$time [$level]$levelpad node=$node $metadata$message\n",
  metadata: [:request_id]
