defmodule TrainLoc.Utilities.Time do

    @spec local_now(Timex.Types.valid_timezone) :: DateTime.t | Timex.AmbiguousDateTime.t | {:error, term}
    def local_now(timezone \\ Application.get_env(:trainloc, :time_zone)) do
        Timex.now(timezone)
    end

    @spec end_of_service_date(Datetime.t) :: Datetime.t
    def end_of_service_date(current_time \\ local_now()) do
        datetime = current_time |> Timex.end_of_day |> Timex.shift(hours: 3)
        if current_time.hour < 3 do
            Timex.shift(datetime, days: -1)
        else
            datetime
        end
    end

    @spec time_until(Datetime.t, Datetime.t, Timex.Comparable.granularity) :: integer
    def time_until(time, from, units \\ :milliseconds) do
        Timex.diff(time, from, units)
    end

    @spec get_service_date(Datetime.t) :: Date.t
    def get_service_date(current_time \\ local_now()) do
        datetime = Timex.beginning_of_day(current_time)
        service_datetime =
        if current_time.hour < 3 do
            Timex.shift(datetime, days: -1)
        else
            datetime
        end
        Timex.to_date(service_datetime)
    end
end
