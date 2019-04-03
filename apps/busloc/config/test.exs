use Mix.Config

config :busloc, start?: false

config :busloc, Operator, cmd: Busloc.Cmd.Fake
config :busloc, TmShuttle, cmd: Busloc.Cmd.Fake

config :busloc,
  uploaders: [
    %{
      states: [:transitmaster_state, :eyeride_state, :saucon_state],
      uploader: Busloc.TestUploader,
      encoder: Busloc.Encoder.NextbusXml,
      filename: "nextbus.xml"
    }
  ]
