
defmodule TrainLoc.LoggingTest do
  use ExUnit.Case
  import TrainLoc.Logging

  describe "log_string/2" do
    test "given a map returns a correctly formatted iolist" do
      expected = "Hi - hello=world"
      iolist = log_string("Hi", %{hello: :world})
      assert :erlang.iolist_to_binary(iolist) == expected
    end

    test "given a keyword list returns a correctly formatted iolist" do
      expected = "Hi - hello=world"
      iolist = log_string("Hi", hello: :world)
      assert :erlang.iolist_to_binary(iolist) == expected
    end

    test "given an atom returns a correctly formatted iolist with `reason` as the key" do
      expected = "Hi - reason=because"
      iolist = log_string("Hi", :because)
      assert :erlang.iolist_to_binary(iolist) == expected
    end
  end
end
