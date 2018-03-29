defmodule Busloc.Uploader.FileTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.Uploader.File

  describe "upload/1" do
    @tag :capture_log
    test "write out to a file" do
      body = "body"

      upload(body)

      assert File.exists?("nextbus.xml")
      assert File.read!("nextbus.xml") == body
    end
  end
end
