use Mix.Config

config :busloc, :uploader, Busloc.Uploader.Web

config :busloc, Uploader.Web,
  bucket_name: {:system, "S3_BUCKET"},
  bucket_prefix: {:system, "S3_BUCKET_PREFIX"},
  nextbus_url: {:system, "NEXTBUS_URL"}

config :logger, backends: [{Logger.Backend.Splunk, :splunk}, :console]

config :logger, :splunk,
  host: "https://http-inputs-mbta.splunkcloud.com/services/collector/event",
  token: {:system, "SPLUNK_TOKEN"},
  level: :debug,
  format: "[$level] $message\n"
