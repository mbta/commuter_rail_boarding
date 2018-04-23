defmodule Busloc.TmFetcherTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.TmFetcher

  describe "handle_info(:timeout)" do
    @tag :capture_log
    test "does not crash on invalid TransitMaster XML" do
      state = %{url: "https://httpbin.org/"}
      assert {:noreply, _state} = handle_info(:timeout, state)
    end

    test "uploads data" do
      bypass = Bypass.open()

      Bypass.expect(bypass, fn conn ->
        Plug.Conn.send_resp(conn, 200, File.read!("test/data/transitmaster.xml"))
      end)

      state = %{url: "http://127.0.0.1:#{bypass.port}"}
      assert {:noreply, _state} = handle_info(:timeout, state)
      assert_receive {:upload, <<_::binary>>}
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
end
