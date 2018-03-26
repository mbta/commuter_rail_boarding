defmodule Busloc.XmlParserTest do
  use ExUnit.Case, async: true
  import Busloc.XmlParser

  describe "parse_transitmaster_xml/1" do
    test "can parse sample output from a file" do
      data = File.read!("test/data/transitmaster.xml")
      parsed = parse_transitmaster_xml(data)
      assert [_ | _] = parsed

      for map <- parsed do
        assert %{vehicle_id: _} = map
      end
    end

    test "can parse output from the new Transitmaster" do
      data = File.read!("test/data/transitmaster_new.xml")
      parsed = parse_transitmaster_xml(data)
      assert [_ | _] = parsed

      for map <- parsed do
        assert %{vehicle_id: _} = map
      end
    end
  end
end
