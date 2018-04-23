use Mix.Config

config :busloc, :uploaders, [
  Busloc.Uploader.S3,
  Busloc.Uploader.Nextbus
]

config :busloc, Uploader.S3,
  bucket_name: {:system, "S3_BUCKET"},
  bucket_prefix: {:system, "S3_BUCKET_PREFIX"}

config :busloc, Uploader.Nextbus, nextbus_url: {:system, "NEXTBUS_URL"}

config :logger, backends: [{Logger.Backend.Splunk, :splunk}, :console]

config :logger, :splunk,
  host: "https://http-inputs-mbta.splunkcloud.com/services/collector/event",
  token: {:system, "SPLUNK_TOKEN"},
  level: :debug,
  format: "[$level] $message\n"
