use Mix.Config

config :busloc,
  uploaders: [
    %{
      states: [:transitmaster_state, :eyeride_state, :saucon_state],
      uploader: Busloc.Uploader.S3,
      encoder: Busloc.Encoder.VehiclePositionsEnhanced,
      filename: "VehiclePositions_enhanced.json",
      bucket_name: {:system, "S3_BUCKET"},
      bucket_prefix: {:system, "S3_BUCKET_PREFIX"}
    },
    %{
      states: [:eyeride_state, :saucon_state],
      uploader: Busloc.Uploader.S3,
      encoder: Busloc.Encoder.VehiclePositionsEnhanced,
      filename: "VehiclePositions_enhanced_shuttles.json",
      bucket_name: {:system, "S3_BUCKET"},
      bucket_prefix: {:system, "S3_BUCKET_PREFIX"}
    }
  ]

config :busloc, Busloc.Tsp.Sender, tsp_url: "http://tspserver.mbta.com/priority?"

config :logger,
  backends: [{Logger.Backend.Splunk, :splunk}, :console],
  sync_threshold: 512,
  discard_threshold: 2048

config :logger, :console, level: :warn

config :logger, :splunk,
  host: "https://http-inputs-mbta.splunkcloud.com/services/collector/event",
  token: {:system, "SPLUNK_TOKEN"},
  level: :debug,
  max_buffer: 512,
  format: "[$level] $message"
