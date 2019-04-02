defmodule Busloc.Cmd.Fake do
  @moduledoc false

  @behaviour Busloc.Cmd

  @impl Busloc.Cmd
  def can_connect? do
    true
  end

  @impl Busloc.Cmd
  def operator_cmd do
    File.read!("test/data/operators.csv")
  end

  @impl Busloc.Cmd
  def shuttle_cmd do
    File.read!("test/data/shuttles.csv")
  end
end
