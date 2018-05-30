use Mix.Config

config :busloc,
  uploaders: [
    %{
      states: [:transitmaster_state, :eyeride_state, :saucon_state],
      uploader: Busloc.Uploader.S3,
      encoder: Busloc.Encoder.NextbusXml,
      filename: "nextbus.xml",
      bucket_name: {:system, "S3_BUCKET"},
      bucket_prefix: {:system, "S3_BUCKET_PREFIX"}
    },
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
    },
    %{
      states: [:transitmaster_state, :eyeride_state, :saucon_state],
      uploader: Busloc.Uploader.Nextbus,
      encoder: Busloc.Encoder.NextbusXml,
      url: {:system, "NEXTBUS_URL"}
    }
  ]

config :logger, backends: [{Logger.Backend.Splunk, :splunk}, :console]

config :logger, :splunk,
  host: "https://http-inputs-mbta.splunkcloud.com/services/collector/event",
  token: {:system, "SPLUNK_TOKEN"},
  level: :debug,
  format: "[$level] $message\n"
