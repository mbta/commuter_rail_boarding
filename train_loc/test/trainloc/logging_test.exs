
defmodule TrainLoc.LoggingTest do
  use ExUnit.Case

  test "splunk_format/2 given a map returns a correctly formatted iolist" do
    expected = "Hi - hello=world"
    iolist = TrainLoc.Logging.log_string("Hi", %{hello: :world})
    assert :erlang.iolist_to_binary(iolist) == expected
  end

  test "splunk_format/2 given a keyword list returns a correctly formatted iolist" do
    expected = "Hi - hello=world"
    iolist = TrainLoc.Logging.log_string("Hi", hello: :world)
    assert :erlang.iolist_to_binary(iolist) == expected
  end

end