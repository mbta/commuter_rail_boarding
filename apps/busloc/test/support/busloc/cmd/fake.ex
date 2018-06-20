defmodule Busloc.Waiver.Cmd.Fake do
  @moduledoc false

  @behaviour Busloc.Waiver.Cmd

  @impl Busloc.Waiver.Cmd
  def can_connect? do
    true
  end

  @impl Busloc.Waiver.Cmd
  def cmd do
    File.read!("test/data/waivers.csv")
  end
end
