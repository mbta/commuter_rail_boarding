defmodule Busloc.Uploader.S3Test do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Uploader.S3

  describe "s3_request/1" do
    setup do
      old_env = Application.get_env(:busloc, Uploader.S3)

      on_exit(fn ->
        Application.put_env(:busloc, Uploader.S3, old_env)
      end)

      Application.put_env(
        :busloc,
        Uploader.S3,
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
end
