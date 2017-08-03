use Mix.Config

config :commuter_rail_boarding,
  firebase_url: {:system, "FIREBASE_URL"},
  uploader: Uploader.S3

config :commuter_rail_boarding, Uploader.S3,
  requestor: ExAws,
  bucket: {:system, "S3_BUCKET"}
