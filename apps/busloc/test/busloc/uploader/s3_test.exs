defmodule Busloc.Uploader.S3Test do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Uploader.S3

  describe "s3_request/2" do
    test "returns an S3 request to upload the given data" do
      request =
        s3_request("body", %{
          bucket_name: "bucket",
          bucket_prefix: "prefix/path",
          filename: "nextbus.xml"
        })

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

    test "calculates the content type based on the filename" do
      request =
        s3_request("body", %{
          bucket_name: "bucket",
          bucket_prefix: "prefix/path",
          filename: "enhanced.json"
        })

      assert request.headers["content-type"] == "application/json"
    end
  end
end
