use Mix.Config

config :busloc, :uploader, Busloc.Uploader.S3

config :busloc, Uploader.S3,
  bucket_name: {:system, "S3_BUCKET"},
  bucket_prefix: {:system, "S3_BUCKET_PREFIX"}

config :logger, backends: [{Logger.Backend.Splunk, :splunk}, :console]

config :logger, :splunk,
  host: "https://http-inputs-mbta.splunkcloud.com/services/collector/event",
  token: {:system, "SPLUNK_TOKEN"},
  level: :debug,
  format: "[$level] $message\n"
