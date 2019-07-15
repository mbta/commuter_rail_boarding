defmodule Busloc.Cmd.Sqlcmd do
  @moduledoc """
  Executes a `sqlcmd` script to retrieve the operator, shuttle, or dispatcher-assigned logon data.
  """
  @behaviour Busloc.Cmd
  require Logger

  def operator_sql do
    ~s[DECLARE @max_calendar_id as numeric(10,0);
      set @max_calendar_id = (select max(calendar_id)
        FROM TMDailylog.dbo.DAILY_WORK_PIECE);
      SELECT PROPERTY_TAG as 'vehicle_id'
        ,LAST_NAME as 'operator_name'
        ,ONBOARD_LOGON_ID as 'operator_id'
        ,BLOCK_ABBR as 'block_id'
        ,RUN_DESIGNATOR AS 'run_id'
      FROM TMDailylog.dbo.DAILY_WORK_PIECE
      INNER JOIN tmmain.dbo.VEHICLE ON current_vehicle_id = vehicle.vehicle_id
      INNER JOIN tmmain.dbo.operator ON current_operator_id = operator.operator_id
      INNER JOIN tmmain.dbo.work_piece ON daily_work_piece.work_piece_id = work_piece.work_piece_id
      INNER JOIN tmmain.dbo.block ON work_piece.block_id = block.block_id
      INNER JOIN tmmain.dbo.run ON work_piece.run_id = run.run_id
      WHERE calendar_id = @max_calendar_id
        AND  actual_logoff_time IS NULL
      ORDER BY PROPERTY_TAG]
  end

  def shuttle_sql do
    ~s[DECLARE @max_calendar_id as numeric(10,0);
      set @max_calendar_id = (select max(calendar_id)
        FROM TMDailylog.dbo.DAILY_WORK_PIECE);
      SELECT PROPERTY_TAG as 'vehicle_id'
	  ,LAST_NAME as 'operator_name'
      ,CURRENT_DRIVER as 'operator_id'
      ,MDT_BLOCK_ID as 'block_id'
      ,SYSPARAM_FLAG as 'run_id'
      FROM TMDailylog.Dbo.LOGGED_MESSAGE
      INNER JOIN TMMain.dbo.Vehicle on source_host = RNET_ADDRESS
      INNER JOIN TMMain.dbo.Operator on current_driver = Operator.ONBOARD_LOGON_ID
      WHERE calendar_id = @max_calendar_id
        AND message_type_id = 9
        AND cat_6 = 1
        AND SYSPARAM_FLAG like '999050%'
        AND transmitted_message_id IN
          (SELECT max(transmitted_message_id) 
           FROM TMDailylog.dbo.LOGGED_MESSAGE
           WHERE calendar_id = @max_calendar_id
           AND message_type_id = 9
           GROUP BY source_host
          )]
  end

  def assigned_logon_sql do
    ~s[DECLARE @secs_since_midnight as numeric(5,0);
      set @secs_since_midnight = DATEDIFF(SECOND, 0, Convert(Time, GetDate()));
      declare @service_date as numeric(5,0);
      if @secs_since_midnight > 10800    -- After 3 AM: service date is not a continuation of previous day
      BEGIN
        set @service_date = datediff(d, 0, getdate())
      END
      ELSE                       -- It's now between midnight and 3 AM: adjust to count from start of previous day
      BEGIN
        set @service_date = datediff(d, 0, getdate()) - 1;
        set @secs_since_midnight = @secs_since_midnight + 86400
      END
      SELECT vehicle.PROPERTY_TAG as vehicle_id
      ,operator.ONBOARD_LOGON_ID as 'operator_id'
      ,operator.LAST_NAME as 'operator_name'
      ,BLOCK_ABBR as 'block_id'
      ,RUN_DESIGNATOR as 'run_id'
      FROM TMDailylog.dbo.OPERATOR_ACTIVITY
      inner join  -- Only the most recent entry for each vehicle
        (SELECT assigned_vehicle_id, max(TIME) AS MaxDateTime
          FROM (SELECT * from TMDailylog.dbo.OPERATOR_ACTIVITY WHERE OPERATOR_ACTIVITY.TIME > datediff(d, 0, getdate())) 
	        AS TODAY_OPERATOR_ACTIVITY
          inner join tmdailylog.dbo.DAILY_WORK_PIECE 
          on TODAY_OPERATOR_ACTIVITY.WORK_PIECE_ID = DAILY_WORK_PIECE.DAILY_WORK_PIECE_ID
          GROUP BY assigned_vehicle_id) groupedVehicles 
        ON assigned_vehicle_id = groupedVehicles.assigned_vehicle_id 
        AND OPERATOR_ACTIVITY.TIME = groupedVehicles.MaxDateTime
      inner join tmdailylog.dbo.DAILY_WORK_PIECE on operator_activity.WORK_PIECE_ID = DAILY_WORK_PIECE.DAILY_WORK_PIECE_ID
      inner join tmmain.dbo.vehicle on DAILY_WORK_PIECE.ASSIGNED_VEHICLE_ID = vehicle.vehicle_id
      inner join tmmain.dbo.operator on operator_activity.OPERATOR_ID = OPERATOR.OPERATOR_ID
      inner join tmmain.dbo.block on operator_activity.block_id = block.block_id
      inner join tmmain.dbo.run on daily_work_piece.run_id = run.run_id
      where time > @service_date
      and @secs_since_midnight > (BEGIN_TIME - 600) -- include 10 minutes before run start
      and @secs_since_midnight < (END_TIME + 1200)  -- include 20 minutes after run end
      and daily_work_piece.current_operator_id is null  -- limit to failed logons
      ]
  end

  @impl Busloc.Cmd
  def can_connect? do
    case System.cmd("sqlcmd", ["-l", "1", "-Q", "select 1"], stderr_to_stdout: true) do
      {_, 0} -> true
      _ -> false
    end
  rescue
    ErlangError -> false
  end

  @impl Busloc.Cmd
  def operator_cmd(), do: call_sql_cmd(cmd_list(operator_sql()))

  @impl Busloc.Cmd
  def shuttle_cmd(), do: call_sql_cmd(cmd_list(shuttle_sql()))

  @impl Busloc.Cmd
  def assigned_logon_cmd(), do: call_sql_cmd(cmd_list(assigned_logon_sql()))

  @spec cmd_list(query :: String.t()) :: [String.t()]
  def cmd_list(query) do
    cmd_list = [
      "-s",
      ",",
      "-Q",
      query
    ]

    Logger.debug(fn ->
      "TM SQL command: #{query}"
    end)

    cmd_list
  end

  defp call_sql_cmd(cmd_list) do
    {data, 0} = System.cmd("sqlcmd", cmd_list, stderr_to_stdout: true)
    data
  end

  @line_splitter ~r/\r?\n/
  @col_splitter ~r/\s*,\s*/

  @type key :: {String.t(), String.t()}

  @spec parse(String.t()) :: [map]
  def parse(data) do
    rows = Regex.split(@line_splitter, data)
    [headers, _ignored | rest] = rows
    headers = split_and_trim(@col_splitter, headers)

    for row <- rest do
      row = String.trim_leading(row)
      columms = split_and_trim(@col_splitter, row)
      header_column_pairs = Enum.zip(headers, columms)
      Map.new(header_column_pairs)
    end
  end

  defp split_and_trim(regex, string) do
    regex
    |> Regex.split(string)
    |> Enum.map(&String.trim/1)
  end
end
