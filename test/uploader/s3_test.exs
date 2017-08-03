defmodule Uploader.S3Test do
  @moduledoc false
  use ExUnit.Case

  import Uploader.S3

  setup do
    old_config = Application.get_env(:commuter_rail_boarding, Uploader.S3)
    on_exit fn ->
      Application.put_env(:commuter_rail_boarding, Uploader.S3, old_config)
    end

    config = Keyword.merge(old_config || [],[
          requestor: __MODULE__.MockAws,
          bucket: "test_bucket"
                       ])
    Application.put_env(:commuter_rail_boarding, Uploader.S3, config)
    :ok
  end

  describe "upload/1" do
    test "uploads to a configured S3 bucket" do
      assert :ok = upload("binary")
      assert_received {:aws_request, request}
      assert request.path == "TripUpdates_enhanced.json"
      assert request.bucket == "test_bucket"
      assert request.body == "binary"
      assert request.headers["content-type"] == "application/json"
      assert request.headers["x-amz-acl"] == "public-read"
    end
  end

  defmodule MockAws do
    def request!(request) do
      send self(), {:aws_request, request}
      :ok
    end
  end
end
