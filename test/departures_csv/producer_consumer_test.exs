defmodule DeparturesCSV.ProducerConsumerTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import DeparturesCSV.ProducerConsumer
  alias BoardingStatus

  describe "handle_events/3" do
    test "returns a Departures.csv file" do
      {_, state, _} = init([])

      statuses = [
        %BoardingStatus{
          stop_id: "North Station",
          trip_id: "CR-Weekday-Spring-18-315",
          direction_id: 0,
          scheduled_time: DateTime.from_unix!(1_518_797_520),
          status: :on_time
        },
        %BoardingStatus{
          stop_id: "South Station",
          trip_id: "CR-Weekday-Spring-18-707",
          direction_id: 0,
          scheduled_time: DateTime.from_unix!(1_518_796_800),
          track: "2",
          status: :all_aboard
        }
      ]

      assert {:noreply, [{"Departures.csv", "TimeStamp" <> _}], ^state} =
               handle_events([statuses], :from, state)
    end
  end
end
