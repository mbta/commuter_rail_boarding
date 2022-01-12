defmodule TrainLoc.Manager.EventJsonParser do
  @moduledoc """
  Used to parse and validate binary `data` from the `ServerSentEvent`.

  This module is concerned with extracting a json_map from a string,
  extracting vehicles_json maps from the json_map, extracting a date from json_map,
  and finally validating the extracted vehicle_json maps.

  A failure to validate any vehicle_json map will result in an error tuple.
  """

  alias TrainLoc.Manager.Event
  alias TrainLoc.Vehicles.JsonValidator

  @spec parse(String.t() | map()) ::
          {:error, any}
          | {:ok, Event.t()}
  def parse(data) when is_binary(data) do
    case Jason.decode(data, strings: :copy) do
      {:ok, json} -> parse(json)
      {:error, error} -> {:error, error}
    end
  end

  def parse(data) when is_map(data) do
    with vehicles_json <- extract_vehicles_json(data),
         date <- extract_date(data),
         :ok <- validate_vehicles_json(vehicles_json) do
      {:ok,
       %Event{
         vehicles_json: vehicles_json,
         date: date
       }}
    else
      {:error, %Jason.DecodeError{}} ->
        {:error, :invalid_json}

      {:error, _} = err ->
        err

      _ ->
        {:error, :invalid_json}
    end
  end

  def parse(_) do
    {:error, :invalid_json}
  end

  defp validate_vehicles_json(vehicles_json) when is_list(vehicles_json) do
    Enum.reduce(vehicles_json, :ok, fn
      vehicle, :ok ->
        JsonValidator.validate(vehicle)

      _, {:error, _} = err ->
        err
    end)
  end

  @spec extract_vehicles_json(map()) :: [map()]
  def extract_vehicles_json(%{"data" => %{"results" => json}})
      when is_map(json) do
    extract_vehicles_json(json)
  end

  def extract_vehicles_json(%{"VehicleID" => _} = json) do
    [json]
  end

  def extract_vehicles_json(json) when is_map(json) do
    Enum.reduce(json, [], fn
      {_key, %{"VehicleID" => _} = vehicle_json}, acc ->
        [vehicle_json | acc]

      _, acc ->
        acc
    end)
  end

  def extract_vehicles_json(_) do
    nil
  end

  @spec extract_date(map()) :: String.t() | nil
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
