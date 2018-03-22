defmodule Busloc.TmFetcher do

  def get() do
    get(Application.get_env(:busloc, :transitmaster_url))
  end
  def get(url) do
    headers = [
      {"Accept", "text/xml"}
    ]

    {:ok, xml_response} = HTTPoison.get(url, headers)

    xml_response.body
  end

end
