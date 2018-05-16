defmodule Busloc.Supervisor.Eyeride do
  @moduledoc """
  Supervisor for the Eyeride state and fetcher.
  """
  import Busloc.Utilities.ConfigHelpers

  def start_link do
    children = [
      {Busloc.State, name: :eyeride_state},
      {Busloc.Fetcher.EyerideFetcher,
       host: config(EyerideFetcher, :host),
       email: config(EyerideFetcher, :email),
       password: config(EyerideFetcher, :password),
       state: :eyeride_state}
    ]

    Supervisor.start_link(children, strategy: :rest_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      type: :supervisor,
      start: {__MODULE__, :start_link, []}
    }
  end
end
