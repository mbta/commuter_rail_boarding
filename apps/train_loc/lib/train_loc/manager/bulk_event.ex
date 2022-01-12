defmodule TrainLoc.Manager.BulkEvent do
  @moduledoc """
  Contains the schema and parsing functions for parsing the new Keolis bulk AVL
  feed format.
  """
  alias TrainLoc.Vehicles.Vehicle

  @schema %{
            "$schema" => "http://json-schema.org/draft-07/schema",
            "title" => "Bulk Keolis AVL Event",
            "description" => "Keolis's new bulk AVL event format",
            "type" => "object",
            "properties" => %{
              "path" => %{"type" => "string"},
              "data" => %{
                "type" => "object",
                "properties" => %{
                  "processResults" => %{
                    "type" => "object",
                    "properties" => %{
                      "date" => %{"type" => "string"},
                      "results" => %{"type" => "integer"}
                    },
                    "required" => ["date", "results"]
                  },
                  "results" => %{
                    "type" => "object",
                    "additionalProperties" => %{
                      "type" => "object",
                      "properties" => %{
                        "Heading" => %{"type" => "number"},
                        "Latitude" => %{"type" => "number"},
                        "Longitude" => %{"type" => "number"},
                        "Source" => %{"type" => "string"},
                        "Speed" => %{"type" => "integer"},
                        "TripID" => %{"type" => "string"},
                        "Update Time" => %{"type" => "string", "format" => "date-time"},
                        "VehicleID" => %{"type" => "integer"}
                      },
                      "required" => [
                        "VehicleID",
                        "Heading",
                        "Latitude",
                        "Longitude",
                        "Speed",
                        "TripID",
                        "Update Time"
                      ]
                    }
                  }
                },
                "required" => ["processResults", "results"]
              }
            },
            "required" => ["data", "path"]
          }
          |> ExJsonSchema.Schema.resolve()

  @spec valid_json?(map) :: boolean
  def valid_json?(event) when is_map(event),
    do: ExJsonSchema.Validator.valid?(@schema, event)

  @spec parse(map | String.t()) ::
          {:ok, [Vehicle.t()]}
          | {:error, :invalid_event, map}
          | {:error, Jason.DecodeError.t()}
  def parse(event) when is_map(event) do
    if valid_json?(event) do
      {:ok,
       event["data"]["results"]
       |> Map.values()
       |> Enum.map(&Vehicle.from_json/1)}
    else
      {:error, :invalid_event, event}
    end
  end

  def parse(event) when is_binary(event) do
    case Jason.decode(event, strings: :copy) do
      {:ok, event} ->
        parse(event)

      {:error, %Jason.DecodeError{} = error} ->
        {:error, error}
    end
  end
end
