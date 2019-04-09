defmodule Busloc.MapDiff do
  @moduledoc """
  Utilities for comparing maps.
  """

  def get_all(table) do
    Map.new(:ets.tab2list(table))
  end

  @doc """
  Split the `new` map into three maps, relative to the `existing` map:

  - added keys
  - changed keys
  - deleted keys

  Keys which have the same value in `existing` are dropped.
  """
  def split(new, existing) do
    {a, added} = Map.split(new, Map.keys(existing))
    {c, deleted} = Map.split(existing, Map.keys(new))

    changed =
      for {key, value} = tuple <- a, Map.fetch!(c, key) != value, into: %{} do
        tuple
      end

    {added, changed, deleted}
  end
end
