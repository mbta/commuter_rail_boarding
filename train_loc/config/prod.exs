use Mix.Config

config :logger,
    backends: [{Logger.Backend.Logentries, :logentries}, :console]

config :logger, :logentries,
    connector: Logger.Backend.Logentries.Output.SslKeepOpen,
    host: 'data.logentries.com',
    port: 443,
  token: {:system, "LOGENTRIES_TOKEN"},
    format: "$dateT$time [$level]$levelpad $metadata$message\n",
    metadata: [:request_id]

config :trainloc,
    input_ftp_host:     '131.108.88.219',
    input_ftp_user:     'mbtamobile',
    input_ftp_password: 'massbay'
