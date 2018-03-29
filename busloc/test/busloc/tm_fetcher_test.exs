defmodule Busloc.TmFetcherTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Busloc.TmFetcher

  describe "get_xml/1" do
    test "returns {:ok, body} if the response succeeds" do
      assert {:ok, << _ :: binary >>} = get_xml("https://httpbin.org/xml")
    end

    test "returns {:error, _} if the response fails" do
      assert {:error, _} = get_xml("http://doesnotexist.example/")
    end
  end
end
