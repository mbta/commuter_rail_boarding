defmodule HTTPClientTest do
  use ExUnit.Case

  setup do
    old_api_url = Application.get_env(:commuter_rail_boarding, :v3_api_url)
    old_api_key = Application.get_env(:commuter_rail_boarding, :v3_api_key)

    on_exit(fn ->
      Application.put_env(:commuter_rail_boarding, :v3_api_url, old_api_url)
      Application.put_env(:commuter_rail_boarding, :v3_api_key, old_api_key)
    end)

    Application.put_env(:commuter_rail_boarding, :v3_api_url, "the_url")
  end

  describe "process_url/1" do
    test "returns path unchanged when no key provided" do
      Application.put_env(:commuter_rail_boarding, :v3_api_key, nil)

      assert HTTPClient.process_url("/some_path") == "the_url/some_path"
    end

    test "appends api_key using ? when the only query parameter" do
      Application.put_env(:commuter_rail_boarding, :v3_api_key, "the_api_key")

      assert HTTPClient.process_url("/some_path") ==
               "the_url/some_path?api_key=the_api_key"
    end

    test "appends api_key using & when other parameters" do
      Application.put_env(:commuter_rail_boarding, :v3_api_key, "the_api_key")

      assert HTTPClient.process_url("/some_path?query=val") ==
               "the_url/some_path?query=val&api_key=the_api_key"
    end
  end
end
