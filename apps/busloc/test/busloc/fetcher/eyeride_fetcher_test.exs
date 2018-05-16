defmodule Busloc.Fetcher.EyerideFetcherTest do
  use ExUnit.Case
  import Busloc.Fetcher.EyerideFetcher

  describe "init/1" do
    test "logs in and calculates the authorization header" do
      email = "email@example.test"
      password = "password"
      bypass = Bypass.open()

      Bypass.expect(bypass, fn conn ->
        conn = Plug.Parsers.call(conn, Plug.Parsers.init(parsers: [:urlencoded]))
        assert conn.request_path == "/auth/login/"
        assert conn.body_params["email"] == email
        assert conn.body_params["password"] == password

        Plug.Conn.send_resp(conn, 200, File.read!("test/data/eyeride_login.json"))
      end)

      {:ok, state} =
        init(
          host: "127.0.0.1:#{bypass.port}",
          email: email,
          password: password
        )

      assert state.host == "127.0.0.1:#{bypass.port}"
      assert {"authorization", "Token c9120f2ff2db9523d6e6afd53c144d3499529495"} in state.headers
    end

    @tag :capture_log
    test "doesn't start without a host" do
      assert init([]) == :ignore
    end
  end

  describe "handle_info(:timeout)" do
    setup do
      start_supervised!({Busloc.State, name: :eyeride_test_state})
      :ok
    end

    @tag :capture_log
    test "updates vehicle state" do
      bypass = Bypass.open()

      Bypass.expect(bypass, fn conn ->
        case conn.request_path do
          "/auth/login/" ->
            Plug.Conn.send_resp(conn, 200, File.read!("test/data/eyeride_login.json"))

          "/api/statistic/countbyday/" ->
            refute Plug.Conn.get_req_header(conn, "authorization") == []
            Plug.Conn.send_resp(conn, 200, File.read!("test/data/eyeride_countbyday.json"))
        end
      end)

      {:ok, state} =
        init(
          host: "127.0.0.1:#{bypass.port}",
          email: "",
          password: "",
          state: :eyeride_test_state
        )

      assert {:noreply, _state} = handle_info(:timeout, state)
      refute Busloc.State.get_all(:eyeride_test_state) == []
    end
  end
end
