defmodule Busloc.Uploader.NextbusTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Uploader.Nextbus
  import ExUnit.CaptureLog

  describe "upload/2" do
    test "posts the given data to a url" do
      body = "some text"

      fun = fn ->
        assert :ok = upload(body, %{url: "https://httpbin.org/post"})
      end

      assert capture_log(fun) =~ body
    end

    test "logs an error if the upload fails" do
      fun = fn ->
        assert :ok = upload("", %{url: "http://127.0.0.1:0/"})
      end

      assert capture_log(fun) =~ "error"
    end
  end
end
