defmodule ServerSentEvent.ProducerTest do
  use ExUnit.Case
  import ServerSentEvent.Producer

  @moduletag :capture_log

  describe "start_link/1" do
    test "returns a pid when a URL is provided" do
      assert {:ok, pid} = start_link(url: "http://httpbin.org/get")
      assert is_pid(pid)
    end

    test "raises an error if a URL isn't provided" do
      assert_raise KeyError, fn -> start_link([]) end
    end

    test "does not connect to the URL without a consumer" do
      assert {:ok, _pid} = start_link(url: "http://does-not-exist.test")
    end
  end

  describe "handle_info/2" do
    test "ignores a 200 status" do
      state = %ServerSentEvent.Producer{}

      assert {:noreply, [], ^state} =
               handle_info(%HTTPoison.AsyncStatus{code: 200}, state)
    end

    test "crashes on a non-200 status" do
      state = %ServerSentEvent.Producer{}

      assert_raise FunctionClauseError, fn ->
        handle_info(%HTTPoison.AsyncStatus{code: 401}, state)
      end
    end

    test "ignores headers" do
      state = %ServerSentEvent.Producer{}

      assert {:noreply, [], ^state} =
               handle_info(%HTTPoison.AsyncHeaders{}, state)
    end

    test "does nothing with a partial chunk" do
      state = %ServerSentEvent.Producer{}

      assert {:noreply, [], _state} =
               handle_info(%HTTPoison.AsyncChunk{chunk: "data:"}, state)
    end

    test "with a full chunk, returns an event" do
      state = %ServerSentEvent.Producer{}

      assert {:noreply, [], state} =
               handle_info(%HTTPoison.AsyncChunk{chunk: "data:"}, state)

      assert {:noreply, [event], _state} =
               handle_info(%HTTPoison.AsyncChunk{chunk: "data\n\n"}, state)

      assert event.data == "data\n"
    end

    test "reconnects if it receives an `auth_revoked` event" do
      # required for :hackney.close/1
      id = make_ref()
      state = %ServerSentEvent.Producer{id: id}

      assert {:noreply, [_], ^state} =
               handle_info(
                 %HTTPoison.AsyncChunk{
                   id: id,
                   chunk: "event: auth_revoked\n\n"
                 },
                 state
               )

      assert_receive :connect
    end
  end

  describe "bypass" do
    import Plug.Conn

    setup do
      Application.ensure_all_started(:bypass)
      Application.ensure_all_started(:httpoison)
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "sends an event when fully parsed", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        assert get_req_header(conn, "accept") == ["text/event-stream"]
        send_resp(conn, 200, ~s(data: %{}\n\n))
      end)

      start_producer(bypass)
      assert_receive {:events, [%ServerSentEvent{}]}
    end

    test "reconnects when it gets disconnected", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        send_resp(conn, 200, ~s(data: %{}\n\n))
      end)

      start_producer(bypass)
      assert_receive {:events, [%ServerSentEvent{}]}
      Bypass.down(bypass)
      Bypass.up(bypass)
      # should receive another event
      assert_receive {:events, [%ServerSentEvent{}]}
    end

    test "can handle a 307 redirect", %{bypass: bypass} do
      redirect_bypass = Bypass.open()
      # redirect to the other Bypass instance
      Bypass.expect(bypass, fn conn ->
        conn
        |> put_resp_header(
          "Location",
          "http://127.0.0.1:#{redirect_bypass.port}/"
        )
        |> send_resp(307, "")
      end)

      Bypass.expect(redirect_bypass, fn conn ->
        send_resp(conn, 200, ~s(data: %{}\n\n))
      end)

      start_producer(bypass)
      assert_receive {:events, [%ServerSentEvent{}]}
    end

    defp start_producer(bypass) do
      url = "http://127.0.0.1:#{bypass.port}"
      {:ok, producer} = start_link(url: url)

      {:ok, _consumer} =
        __MODULE__.SimpleSubscriber.start_link(self(), producer)
    end
  end

  defmodule SimpleSubscriber do
    @moduledoc """
    Simple consumer which sends the events to a parent PID.
    """
    use GenStage

    def start_link(parent, producer) do
      GenStage.start_link(__MODULE__, {parent, producer})
    end

    def init({parent, producer}) do
      {:consumer, parent, subscribe_to: [producer]}
    end

    def handle_events(events, _from, parent) do
      send(parent, {:events, events})
      {:noreply, [], parent}
    end
  end
end
