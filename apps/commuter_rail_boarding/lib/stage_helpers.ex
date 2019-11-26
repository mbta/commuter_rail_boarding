defmodule StageHelpers do
  @moduledoc """
  Small helpers for GenStage modules
  """

  @doc """
  Adds the name as an option if provided.
  """
  def start_link_opts(args) do
    if name = Keyword.get(args, :name) do
      [name: name]
    else
      []
    end
  end

  @doc """
  Adds stage subscriptions as an option if provided.
  """
  def init_opts(args) do
    opts =
      if subscribe_to = Keyword.get(args, :subscribe_to) do
        [subscribe_to: List.wrap(subscribe_to)]
      else
        []
      end

    opts ++ Keyword.take(args, [:dispatcher])
  end
end
