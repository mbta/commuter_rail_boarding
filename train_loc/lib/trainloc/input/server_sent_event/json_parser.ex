defmodule TrainLoc.Input.ServerSentEvent.JsonParser do

  def parse(data) when is_binary(data) do
    case Poison.decode(data) do
      {:ok, json} ->
        extracted = %{
          vehicles_json: extract_vehicles_json(json),
          date: extract_date(json),
        }
        {:ok, extracted}
      _ ->
        {:error, :invalid_json}
    end
  end

  def extract_vehicles_json(%{"vehicleid" => _} = json) do
    [json]
  end
  def extract_vehicles_json(json) do
    json
    |> Enum.reduce([], fn
      ({_key, %{"vehicleid" => _} = vehicle_json}, acc) ->
        [ vehicle_json | acc ]
      (_, acc) -> 
        acc
    end)
  end

  def extract_date(%{"data" => json}) do
    extract_date(json)
  end
  def extract_date(%{"date" => date}) do
    date
  end
  def extract_date(_) do
    nil
  end

end