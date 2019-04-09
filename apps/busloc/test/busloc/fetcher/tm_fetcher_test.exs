defmodule Busloc.Fetcher.TmFetcherTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  import Busloc.Fetcher.TmFetcher
  import Busloc.Utilities.ConfigHelpers
  alias Busloc.Utilities.Time, as: BuslocTime

  describe "init/1" do
    @tag :capture_log
    test "doesn't start if the URL is nil" do
      assert init(nil) == :ignore
    end
  end

  describe "handle_info(:timeout)" do
    setup do
      start_supervised!({Busloc.State, name: :transitmaster_state})
      start_supervised!({Busloc.Fetcher.OperatorFetcher, []})
      start_supervised!({Busloc.Fetcher.TmShuttleFetcher, []})
      bypass = Bypass.open()
      {:ok, state} = init("http://127.0.0.1:#{bypass.port}")
      %{state: state, bypass: bypass}
    end

    @tag :capture_log
    test "does not crash on invalid TransitMaster XML", %{state: state} do
      state = %{state | url: "https://httpbin.org/"}
      assert {:noreply, _state} = handle_info(:timeout, state)
    end

    @tag :capture_log
    test "stores data in Busloc.State", %{state: state, bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.send_resp(conn, 200, File.read!("test/data/transitmaster.xml"))
      end)

      assert {:noreply, _state} = handle_info(:timeout, state)
      refute Busloc.State.get_all(:transitmaster_state) == []
    end

    @tag :capture_log
    test "merges operator data", %{state: state, bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.send_resp(conn, 200, File.read!("test/data/transitmaster.xml"))
      end)

      assert {:noreply, _state} = handle_info(:timeout, state)

      assert %Busloc.Vehicle{operator_name: "DIXON", operator_id: "65494", run: "128-1407"} =
               Busloc.State.get(:transitmaster_state, "0401")
    end

    @tag :capture_log
    test "merges shuttle data", %{state: state, bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.send_resp(conn, 200, File.read!("test/data/transitmaster.xml"))
      end)

      assert {:noreply, _state} = handle_info(:timeout, state)

      assert %Busloc.Vehicle{
               operator_name: "SANDERS",
               operator_id: "71158",
               block: "9990501",
               run: "9990501"
             } = Busloc.State.get(:transitmaster_state, "0688")
    end
  end

  describe "get_xml/1" do
    test "returns {:ok, body} if the response succeeds" do
      assert {:ok, <<_::binary>>} = get_xml("https://httpbin.org/xml")
    end

    test "returns {:error, _} if the response fails" do
      assert {:error, _} = get_xml("http://doesnotexist.example/")
    end
  end

  describe "log_if_all_stale/1" do
    test "logs if all TransitMaster vehicles are stale" do
      stale_time = Timex.shift(BuslocTime.now(), seconds: -config(TmFetcher, :stale_seconds) - 5)

      vehicles = [
        %Busloc.Vehicle{
          vehicle_id: "1111",
          block: "A123-45",
          latitude: 42.2222,
          longitude: -71.1111,
          heading: 45,
          source: :transitmaster,
          timestamp: stale_time
        },
        %Busloc.Vehicle{
          vehicle_id: "2222",
          block: "B98-765",
          latitude: 42.1111,
          longitude: -71.2222,
          heading: 135,
          source: :transitmaster,
          timestamp: stale_time
        }
      ]

      fun = fn -> log_if_all_stale(vehicles) end

      expected_log = "Transitmaster data is stale."

      assert capture_log(fun) =~ expected_log
    end
  end
end
