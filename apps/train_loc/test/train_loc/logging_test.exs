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

    test "given an error tuple, renders it with reason as the key" do
      expected = ~s(Error - reason={:invalid, "p", 48})
      iolist = log_string("Error", {:invalid, "p", 48})
      assert :erlang.iolist_to_binary(iolist) == expected
    end

    test "given a list as one of the values, renders it as JSON" do
      expected = ~s(Hi - list=[1,"2"])
      iolist = log_string("Hi", %{list: [1, "2"]})
      assert :erlang.iolist_to_binary(iolist) == expected
    end
  end
end
