defmodule DeparturesCSV do
  @moduledoc """
  Renders a list of BoardingStatus structs as a Departures.csv binary.

  ## Example

      TimeStamp,Origin,Trip,Destination,ScheduledTime,Lateness,Track,Status
      1518796775,"North Station","315","Lowell",1518797520,0,,"On Time"
      1518796775,"South Station","707","Forge Park / 495",1518796800,0,"2","All Aboard"
  """

  @headers Enum.join(~w(TimeStamp Origin Trip Destination ScheduledTime Lateness Track Status), ",")
  @headsigns Application.get_env(:commuter_rail_boarding, :headsigns)

  def to_binary(statuses, unix_now \\ DateTime.to_unix(DateTime.utc_now())) do
    rows = for status <- sort_filter(statuses, unix_now) do
      row(status, unix_now)
    end
    as_csv(rows)
  end

  def sort_filter(statuses, unix_now) do
    statuses
    |> Enum.filter(&should_be_in_output?(&1, unix_now))
    |> Enum.sort_by(&sort_key/1)
  end

  def row(status, unix_now) do
    {:ok, name, headsign} = TripCache.trip_name_headsign(status.trip_id)
    [
      unix_now,
      status.stop_id,
      name,
      Map.get(@headsigns, headsign, headsign),
      DateTime.to_unix(status.scheduled_time),
      lateness(status.scheduled_time, status.predicted_time),
      status.track,
      boarding_status(status.status)
    ]
  end

  defp as_csv(rows) do
    row_strings = for row <- rows do
      item_strings = for item <- row do
        case item do
          int when is_integer(int) ->
            Integer.to_string(int)
          "" ->
            ""
          other ->
            inspect(other)
        end
      end
      Enum.join(item_strings, ",")
    end
    Enum.join([@headers | row_strings], "\n") <> "\n"
  end

  defp should_be_in_output?(%{stop_id: stop_id}, _) when stop_id not in ["North Station", "South Station"] do
    false
  end
  defp should_be_in_output?(%{direction_id: direction_id}, _) when direction_id != 0 do
    false
  end
  defp should_be_in_output?(%{status: :departed, predicted_time: time}, unix_now) do
    DateTime.to_unix(time) > unix_now - 60
  end
  defp should_be_in_output?(_, _) do
    true
  end

  defp sort_key(status) do
    time = if status.predicted_time == :unknown do
      0
    else
      DateTime.to_unix(status.predicted_time)
    end
    {status.stop_id, time}
  end

  defp lateness(%DateTime{} = scheduled_time, %DateTime{} = predicted_time) do
    if DateTime.compare(scheduled_time, predicted_time) == :lt do
      DateTime.to_unix(predicted_time) - DateTime.to_unix(scheduled_time)
    else
      0
    end
  end
  defp lateness(_, _) do
    0
  end

  defp boarding_status(atom) do
    atom
    |> Atom.to_string
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
