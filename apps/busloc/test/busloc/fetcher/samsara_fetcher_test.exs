defmodule Busloc.Fetcher.SamsaraFetcherTest do
  use ExUnit.Case
  import Busloc.Fetcher.SamsaraFetcher

  describe "init/1" do
    @tag :capture_log
    test "doesn't start if the URL is nil" do
      assert init(nil) == :ignore
    end
  end

  describe "handle_info(:timeout)" do
    setup do
      start_supervised!({Busloc.State, name: :transitmaster_state})
      :ok
    end

    @tag :capture_log
    test "updates vehicle state" do
      bypass = Bypass.open()

      Bypass.expect(bypass, fn conn ->
        Plug.Conn.send_resp(conn, 200, File.read!("test/data/samsara.json"))
      end)

      {:ok, state} = init("http://127.0.0.1:#{bypass.port}")
      assert {:noreply, _state} = handle_info(:timeout, state)
      refute Busloc.State.get_all(:transitmaster_state) == []
    end
  end
end
