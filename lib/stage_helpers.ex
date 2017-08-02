defmodule StageHelpers do
  def start_link_opts(args) do
    if name = Keyword.get(args, :name) do
      [name: name]
    else
      []
    end
  end

  def init_opts(args) do
    if subscribe_to = Keyword.get(args, :subscribe_to) do
      [subscribe_to: List.wrap(subscribe_to)]
    else
      []
    end
  end
end
