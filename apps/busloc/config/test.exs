use Mix.Config

config :busloc, TmFetcher, start?: false

config :busloc, :uploaders, [Busloc.TestUploader]
