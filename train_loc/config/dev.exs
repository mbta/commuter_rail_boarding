use Mix.Config

config :logger,
    backends: [:console]

config :logger, :console,
    level: :debug

config :trainloc,
    input_ftp_host: 'localhost',
    input_ftp_user: 'ftpuser',
    input_ftp_password: 'password',
    input_ftp_file_name: "AVLData.txt"
