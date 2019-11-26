defmodule TrainLoc.Utilities.FirebaseUrlTest do
  use ExUnit.Case, async: true
  import TrainLoc.Utilities.FirebaseUrl

  describe "url/1" do
    test "returns the firebase URL plus an access token" do
      value = url(token_fn: fn -> "test token" end)
      assert value =~ ~r/[?&]access_token=test token/
    end
  end
end
