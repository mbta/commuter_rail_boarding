defmodule Busloc.Waiver.Cmd do
  @moduledoc """
  Executes a `sqlcmd` script to retrieve the waiver data.
  """
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

  @spec can_connect?() :: boolean
  def can_connect? do
    case System.cmd("sqlcmd", ["-l", "1", "-Q", "select 1"], stderr_to_stdout: true) do
      {_, 0} -> true
      _ -> false
    end
  end

  @spec cmd() :: String.t()
  def cmd do
    query = sql()

    cmd = [
      "-s",
      ",",
      "-Q",
      query
    ]

    Logger.debug(fn ->
      "executing TM query: #{query}"
    end)

    {data, 0} = System.cmd("sqlcmd", cmd, stderr_to_stdout: true)
    data
  end

  def calendar_id do
    "America/New_York"
    |> Timex.now()
    |> Timex.format!("1{YYYY}{0M}{0D}")
  end
end
