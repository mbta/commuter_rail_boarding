defmodule Busloc.Uploader.WebTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Uploader.Web
  import ExUnit.CaptureLog

  describe "s3_request/1" do
    setup do
      old_env = Application.get_env(:busloc, Uploader.Web)

      on_exit(fn ->
        Application.put_env(:busloc, Uploader.Web, old_env)
      end)

      Application.put_env(
        :busloc,
        Uploader.Web,
        bucket_name: "bucket",
        bucket_prefix: "prefix/path"
      )

      :ok
    end

    test "returns an S3 request to upload the given data" do
      request = s3_request("body")

      assert %ExAws.Operation.S3{
               bucket: "bucket",
               path: "prefix/path/nextbus.xml",
               body: "body",
               headers: %{
                 "x-amz-acl" => "public-read",
                 "content-type" => "text/xml"
               }
             } = request
    end
  end

  describe "post_nextbus/1" do
    setup do
      old_env = Application.get_env(:busloc, Uploader.Web)

      on_exit(fn ->
        Application.put_env(:busloc, Uploader.Web, old_env)
      end)

      Application.put_env(
        :busloc,
        Uploader.Web,
        nextbus_url: "https://httpbin.org/post"
      )

      :ok
    end

    test "posts the given data to a url" do
      body = "some text"

      fun = fn ->
        post_nextbus(body)
      end

      assert capture_log(fun) =~ body
    end
  end
end
