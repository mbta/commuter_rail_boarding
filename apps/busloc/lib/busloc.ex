defmodule Busloc do
  @moduledoc """
  Documentation for Busloc.
  """
  use Application
  import Busloc.Utilities.ConfigHelpers

  def start(_type, _args) do
    children =
      if config(:start?) do
        children()
      else
        []
      end

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def children do
    [
      Busloc.Supervisor.Eyeride,
      Busloc.Supervisor.Transitmaster,
      Busloc.Supervisor.Saucon,
      Busloc.Waiver.Server
    ] ++ publisher_children(config(:uploaders))
  end

  defp publisher_children(uploaders) do
    for {uploader, index} <- Enum.with_index(uploaders) do
      uploader = interpolate_uploader(uploader)

      %{
        id: {:publisher, index},
        start: {Busloc.Publisher, :start_link, [uploader]},
        type: :worker
      }
    end
  end

  defp interpolate_uploader(uploader) do
    for {key, value} <- uploader, into: %{} do
      {key, interpolate(value)}
    end
  end
end
