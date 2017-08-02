use Mix.Config

config :commuter_rail_boarding,
  uploader: Uploader.S3

config :commuter_rail_boarding, Uploader.S3,
  requestor: ExAws,
  bucket: {:system, "S3_BUCKET"}
