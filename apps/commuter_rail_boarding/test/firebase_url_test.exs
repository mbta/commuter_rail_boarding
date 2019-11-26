defmodule FirebaseUrlTest do
  use ExUnit.Case, async: true
  import FirebaseUrl

  describe "url/1" do
    test "returns the firebase URL plus an access token" do
      value = url(token_fn: fn -> "test token" end)
      assert value =~ "&access_token=test token"
    end
  end
end
