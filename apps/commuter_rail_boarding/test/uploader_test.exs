defmodule UploaderTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Uploader
  alias TrainLoc.S3

  setup do
    S3.InMemory.start()
    on_exit(fn -> S3.InMemory.stop() end)
  end

  describe "upload/1" do
    test "uploads a binary" do
      assert {:ok, "binary"} = upload("filename", "binary")

      assert S3.InMemory.list_objects() == %{
               "console" => %{
                 "filename" => "binary",
                 "opts" => [acl: :public_read]
               }
             }
    end
  end
end
