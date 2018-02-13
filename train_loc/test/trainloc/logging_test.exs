
defmodule TrainLoc.LoggingTest do
  use ExUnit.Case
  alias ExUnit.CaptureLog

  test "log/2 works with a 0 arity function" do
    expected = "hello=world"
    message_func = fn -> "hello=world" end
    capture_func = fn -> 
      TrainLoc.Logging.log(:debug, message_func)
    end
    captured = CaptureLog.capture_log(capture_func)
    assert captured =~ expected
  end

  test "log/2 works with any map" do
    expected = ~s(hello="world")
    message_map = %{
      hello: "world"
    }
    capture_func = fn -> 
      TrainLoc.Logging.log(:debug, message_map)
    end
    captured = CaptureLog.capture_log(capture_func)
    assert captured =~ expected
  end

  test "log/2 works with a map with a :title key" do
    expected = ~s(This is a test - hello="world")
    message_map = %{
      hello: "world",
      title: "This is a test",
    }
    capture_func = fn -> 
      TrainLoc.Logging.log(:debug, message_map)
    end
    captured = CaptureLog.capture_log(capture_func)
    assert captured =~ expected
  end


  defmodule SomeTestStruct do
    defstruct [:name, :title, :age]
  end

  test "log/2 works with a struct " do
    message_map = %TrainLoc.LoggingTest.SomeTestStruct{
      name: "some_name",
      age: 0,
      title: "This is a struct test",
    }
    capture_func = fn -> 
      TrainLoc.Logging.log(:debug, message_map)
    end
    captured = CaptureLog.capture_log(capture_func)
    assert captured =~ ~s(name="some_name")
    assert captured =~ "age=0"
    assert captured =~ "This is a struct test - "
    assert captured =~ ~s(_module="TrainLoc.LoggingTest.SomeTestStruct")
  end

end