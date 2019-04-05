defmodule Busloc.Cmd.Sqlcmd do
  @moduledoc """
  Executes a `sqlcmd` script to retrieve the operator or shuttle data.
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
  def operator_cmd do
    {data, 0} = System.cmd("sqlcmd", operator_cmd_list(), stderr_to_stdout: true)
    data
  end

  def operator_cmd_list do
    query = operator_sql()

    cmd_list = [
      "-s",
      ",",
      "-Q",
      query
    ]

    Logger.debug(fn ->
      "executing TM operator query: #{query}"
    end)

    cmd_list
  end

  @impl Busloc.Cmd
  def shuttle_cmd do
    {data, 0} = System.cmd("sqlcmd", shuttle_cmd_list(), stderr_to_stdout: true)
    data
  end

  def shuttle_cmd_list do
    query = shuttle_sql()

    cmd_list = [
      "-s",
      ",",
      "-Q",
      query
    ]

    Logger.debug(fn ->
      "executing TM shuttle query: #{query}"
    end)

    cmd_list
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
