use Mix.Config

config :busloc, :uploader, Busloc.Uploader.S3

config :busloc, Uploader.S3,
  bucket_name: {:system, "S3_BUCKET"},
  bucket_prefix: {:system, "S3_BUCKET_PREFIX"}
