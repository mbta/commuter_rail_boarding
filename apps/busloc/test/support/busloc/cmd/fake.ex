defmodule Busloc.Cmd.Fake do
  @moduledoc false

  @behaviour Busloc.Cmd

  @impl Busloc.Cmd
  def can_connect? do
    true
  end

  @impl Busloc.Cmd
  def cmd do
    File.read!("test/data/operators.csv")
  end
end
