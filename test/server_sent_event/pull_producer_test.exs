defmodule ServerSentEvent.PullProducerTest do
  use ExUnit.Case
  import ServerSentEvent.PullProducer
  import Plug.Conn

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

  describe "handle_info(:connect, state)" do
    setup do
      bypass = Bypass.open()
      {_, state} = init({__MODULE__, :url, [bypass]})

      Bypass.stub(bypass, "GET", "/", fn conn ->
        send_resp(conn, 200, ~s(data: %{}\n\n))
      end)

      {:ok, bypass: bypass, state: state}
    end

    test "returns an event", %{state: state} do
      {:noreply, events, _state} = handle_info(:connect, state)
      assert [%ServerSentEvent{}] = events
    end

    test "sends another message", %{state: state} do
      state = %{state | send_after: 0}
      {:noreply, _, _} = handle_info(:connect, state)
      assert_receive :connect
    end

    test "returns no events when there's an error", %{
      state: state,
      bypass: bypass
    } do
      Bypass.down(bypass)
      assert {:noreply, [], _} = handle_info(:connect, state)
    end

    test "sends another message after an error", %{state: state, bypass: bypass} do
      Bypass.down(bypass)
      state = %{state | send_after: 0}
      {:noreply, _, _} = handle_info(:connect, state)
      assert_receive :connect
    end
  end

  describe "handle_demand/2" do
    setup do
      {_, state} = init("not used")

      {:ok, state: state}
    end

    test "sends a message once", %{state: state} do
      assert {:noreply, [], state} = handle_demand(1, state)
      assert_receive :connect
      assert {:noreply, [], _state} = handle_demand(1, state)
      refute_receive :connect
    end
  end

  def url(bypass) do
    "http://127.0.0.1:#{bypass.port}"
  end
end
