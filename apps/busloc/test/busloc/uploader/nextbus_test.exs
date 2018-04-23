defmodule Busloc.Uploader.NextbusTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Uploader.Nextbus
  import ExUnit.CaptureLog

  describe "upload/1" do
    setup do
      old_env = Application.get_env(:busloc, Uploader.Nextbus)

      on_exit(fn ->
        Application.put_env(:busloc, Uploader.Nextbus, old_env)
      end)

      Application.put_env(
        :busloc,
        Uploader.Nextbus,
        nextbus_url: "https://httpbin.org/post"
      )

      :ok
    end

    test "posts the given data to a url" do
      body = "some text"

      fun = fn ->
        assert :ok = upload(body)
      end

      assert capture_log(fun) =~ body
    end
  end
end
