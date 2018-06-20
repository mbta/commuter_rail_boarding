defmodule Busloc.Waiver.Cmd.Sqlcmd do
  @moduledoc """
  Executes a `sqlcmd` script to retrieve the waiver data.
  """
  @behaviour Busloc.Waiver.Cmd
  require Logger

  def sql do
    ~s[SELECT trip.TRIP_SERIAL_NUMBER as TRIP_ID, block.BLOCK_ABBR as BLOCK_ID, \
    route.ROUTE_NAME as ROUTE_ID, gn.GEO_NODE_ABBR as STOP_ID, \
    saw.EARLY_ALLOWED_FLAG, saw.LATE_ALLOWED_FLAG, saw.REMARK, saw.UPDATE_TIMESTAMP as UPDATED_AT, \
    saw.MISSED_ALLOWED_FLAG, saw.NO_REVENUE_FLAG \
    FROM tmdailylog.dbo.sched_adhere_waiver saw \
    JOIN tmdailylog.dbo.stop_crossing sc on saw.WAIVER_ID = sc.WAIVER_ID \
    JOIN tmmain.dbo.geo_node gn on gn.GEO_NODE_ID = sc.GEO_NODE_ID \
    JOIN tmmain.dbo.trip trip on sc.TRIP_ID = trip.TRIP_ID \
    JOIN tmmain.dbo.pattern on trip.PATTERN_ID = pattern.PATTERN_ID \
    JOIN tmmain.dbo.route on pattern.ROUTE_ID = route.ROUTE_ID \
    JOIN tmmain.dbo.block on block.BLOCK_ID = trip.BLOCK_ID \
    WHERE saw.CALENDAR_ID = '#{calendar_id()}' \
          and saw.ENDED_DATE_TIME > SYSDATETIME() \
    ORDER BY UPDATED_AT DESC;]
  end

  @impl Busloc.Waiver.Cmd
  def can_connect? do
    case System.cmd("sqlcmd", ["-l", "1", "-Q", "select 1"], stderr_to_stdout: true) do
      {_, 0} -> true
      _ -> false
    end
  rescue
    ErlangError -> false
  end

  @impl Busloc.Waiver.Cmd
  def cmd do
    {data, 0} = System.cmd("sqlcmd", cmd_list(), stderr_to_stdout: true)
    data
  end

  def cmd_list do
    query = sql()

    cmd_list = [
      "-s",
      ",",
      "-Q",
      query
    ]

    Logger.debug(fn ->
      "executing TM query: #{query}"
    end)

    cmd_list
  end

  def calendar_id do
    Timex.format!(service_date(), "1{YYYY}{0M}{0D}")
  end

  def service_date(now \\ Timex.now("America/New_York"))

  def service_date(%DateTime{} = now) do
    case Timex.shift(now, hours: -3) do
      %DateTime{} = dt -> DateTime.to_date(dt)
      %{before: before} -> DateTime.to_date(before)
    end
  end

  def service_date(%{before: before}) do
    service_date(before)
  end
end
