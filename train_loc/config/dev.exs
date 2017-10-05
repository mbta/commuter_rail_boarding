use Mix.Config

config :logger,
    backends: [:console]

config :logger, :console,
    level: :debug

config :trainloc,
    input_ftp_host: 'localhost',
    input_ftp_user: System.get_env("FTP_USERNAME"),
    input_ftp_password: System.get_env("FTP_PASSWORD")
