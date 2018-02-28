defmodule DateHelpersTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import DateHelpers

  describe "service_date/1" do
    test "returns the current date if it's 3am or after" do
      assert ~D[2017-01-01] = service_date(local_dt(~N[2017-01-01T03:00:00]))
      assert ~D[2017-01-01] = service_date(local_dt(~N[2017-01-01T15:00:00]))
      assert ~D[2017-01-01] = service_date(local_dt(~N[2017-01-01T23:59:59]))
    end

    test "returns the previous date if it's between midnight and 3am" do
      assert ~D[2016-12-31] = service_date(local_dt(~N[2017-01-01T00:00:00]))
      assert ~D[2016-12-31] = service_date(local_dt(~N[2017-01-01T02:59:59]))
    end
  end

  describe "seconds_until_next_service_date/1" do
    test "returns a number of seconds until 3am tomorrow" do
      seconds = seconds_until_next_service_date()
      now = Calendar.DateTime.now!("America/New_York")
      tomorrow = Calendar.DateTime.add!(now, seconds)
      assert {tomorrow.hour, tomorrow.minute, tomorrow.second} == {3, 0, 0}
    end
  end

  defp local_dt(%NaiveDateTime{} = ndt) do
    DateTime.from_naive!(ndt, "Etc/UTC")
  end
end
