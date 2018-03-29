defmodule Busloc.XmlParserTest do
  use ExUnit.Case, async: true
  import Busloc.XmlParser

  describe "parse_transitmaster_xml/1" do
    test "can parse sample output from a file" do
      data = File.read!("test/data/transitmaster.xml")
      {:ok, parsed} = parse_transitmaster_xml(data)
      assert [_ | _] = parsed

      for map <- parsed do
        assert %{vehicle_id: _} = map
      end
    end

    test "can parse output from the new Transitmaster" do
      data = File.read!("test/data/transitmaster_new.xml")
      {:ok, parsed} = parse_transitmaster_xml(data)
      assert [_ | _] = parsed

      for map <- parsed do
        assert %{vehicle_id: _} = map
      end
    end

    test "returns an error when parsing invalid XML" do
      data = "asdf'p;sdiourf;apodsfj;lsdfnhasdjnvsfg"
      assert {:error, :invalid_xml} = parse_transitmaster_xml(data)
    end
  end
end
