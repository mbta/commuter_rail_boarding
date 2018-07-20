defmodule DeparturesCSVTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import DeparturesCSV
  alias BoardingStatus

  @trip_id "CR-Weekday-Spring-18-321"
  @scheduled_time DateTime.from_unix!(12345)

  describe "to_binary/2" do
    test "can return a basic CSV" do
      unix_now = 1_518_796_775

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

      expected = ~s(\
TimeStamp,Origin,Trip,Destination,ScheduledTime,Lateness,Track,Status\r
1518796775,"North Station","315","Lowell",1518797520,0,,"On Time"\r
1518796775,"South Station","707","Forge Park / 495",1518796800,0,"2","All Aboard"\r
)
      actual = to_binary(statuses, unix_now)

      assert expected == actual
    end
  end

  describe "sort_filter/1" do
    test "filters out non-North/South Station and trips in the wrong direction" do
      unix_now = 0

      statuses = [
        %BoardingStatus{stop_id: "North Station", direction_id: 0},
        %BoardingStatus{stop_id: "South Station", direction_id: 1},
        %BoardingStatus{stop_id: "Back Bay", direction_id: 0}
      ]

      expected = Enum.take(statuses, 1)
      actual = sort_filter(Enum.shuffle(statuses), unix_now)

      assert expected == actual
    end

    test "filters out departures after a minute" do
      unix_now = 120

      status = %BoardingStatus{
        stop_id: "North Station",
        direction_id: 0,
        status: :departed
      }

      statuses = [
        %{
          status
          | predicted_time: DateTime.from_unix!(50),
            status: :all_aboard
        },
        %{status | predicted_time: DateTime.from_unix!(100)},
        %{status | predicted_time: DateTime.from_unix!(50)}
      ]

      expected = Enum.take(statuses, 2)
      actual = sort_filter(Enum.shuffle(statuses), unix_now)

      assert expected == actual
    end
  end

  describe "row/2" do
    test "returns basic data" do
      now = 4321

      status = %BoardingStatus{
        trip_id: @trip_id,
        stop_id: "Back Bay",
        scheduled_time: @scheduled_time,
        predicted_time: @scheduled_time,
        track: "5",
        status: :on_time
      }

      expected = [
        4321,
        "Back Bay",
        "321",
        "Lowell",
        12345,
        0,
        "5",
        "On Time"
      ]

      actual = row(status, now)
      assert expected == actual
    end

    test "returns a lateness of 0 if predicted to leave early" do
      now = 4321

      status = %BoardingStatus{
        trip_id: @trip_id,
        stop_id: "Back Bay",
        scheduled_time: @scheduled_time,
        predicted_time: DateTime.from_unix!(12344),
        status: :on_time
      }

      expected = [
        4321,
        "Back Bay",
        "321",
        "Lowell",
        12345,
        0,
        "",
        "On Time"
      ]

      actual = row(status, now)
      assert expected == actual
    end

    test "returns a positive lateness if predicted to leave late" do
      now = 4321

      status = %BoardingStatus{
        trip_id: @trip_id,
        stop_id: "Back Bay",
        scheduled_time: @scheduled_time,
        predicted_time: DateTime.from_unix!(12346),
        status: :on_time
      }

      expected = [
        4321,
        "Back Bay",
        "321",
        "Lowell",
        12345,
        1,
        "",
        "On Time"
      ]

      actual = row(status, now)
      assert expected == actual
    end
  end
end
