
defmodule TrainLoc.LoggingTest do
  use ExUnit.Case
  import TrainLoc.Logging

  describe "log_string/2" do

    defmodule ExampleStruct  do
      defstruct [:name, :age]
    end

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

    test "give a struct returns a correctly formatted iolist" do
      iolist = log_string("Hello", %ExampleStruct{name: "Jim", age: 21})
      string = :erlang.iolist_to_binary(iolist)
      assert string =~ ~s(Hello - )
      assert string =~ ~s(_struct="TrainLoc.LoggingTest.ExampleStruct)
      assert string =~ ~s(name="Jim")
      assert string =~ ~s(age=21)
    end
  end

end