defmodule Busloc.Cmd.Failing do
  @moduledoc false

  @behaviour Busloc.Cmd

  @impl Busloc.Cmd
  def can_connect? do
    false
  end

  @impl Busloc.Cmd
  def operator_cmd do
  end

  @impl Busloc.Cmd
  def shuttle_cmd do
  end

  @impl Busloc.Cmd
  def assigned_logon_cmd do
  end
end
