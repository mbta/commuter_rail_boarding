use Mix.Config

config :busloc, start?: false

config :busloc,
  uploaders: [
    %{
      states: [:transitmaster_state, :eyeride_state, :saucon_state],
      uploader: Busloc.TestUploader,
      encoder: Busloc.Encoder.NextbusXml,
      filename: "nextbus.xml"
    }
  ]
