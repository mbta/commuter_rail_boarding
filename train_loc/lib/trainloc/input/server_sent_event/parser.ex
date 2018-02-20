defmodule TrainLoc.Input.ServerSentEvent.Parser do
  @moduledoc """
  An module for parsing raw
  server sent event binaries.
  """
  alias TrainLoc.Input.ServerSentEvent.{
    Parser,
    LineParser,
    JsonParser,
    VehicleParser,
  }

  defstruct [
    event:    "message",
    binary:   "",
    json:     nil,
    vehicles: [],
    date:     nil,
    errors:   [],
  ]

  @event_types [
    "put",
    "message",
    "keep-alive",
    "auth_revoked",
    "cancel"
  ]

  def parse(string) do
    line = LineParser.parse(string)
    %Parser{
      event: line.event,
      binary: line.binary,
    }
    |> validate_event
    |> parse_json
    |> validate_json
  end


  defp add_error(%__MODULE__{} = parsed, errors) when is_list(errors) do
    %{ parsed | errors: parsed.errors ++ errors}
  end
  defp add_error(%__MODULE__{} = parsed, err) do
    add_error(parsed, [err])
  end

  def validate_event(%Parser{} = parsed) do
    case parsed.event do
      type when type in @event_types ->
        parsed
      invalid_type ->
        err = %{
          expected: @event_types,
          got: invalid_type,
          reason: "Unexpected event type",
        }
        add_error(parsed, err)
    end
  end

  def parse_json(%__MODULE__{} = parsed) do
    case JsonParser.parse(parsed.binary) do
      {:ok, %{date: date, vehicles_json: vehicles_json}} ->
        %{ parsed | json: vehicles_json, date: date }
      {:error, reason} ->
        add_error(parsed, %{reason: reason})
    end
  end

  def parse_event(event) when event in @event_types, do: {:ok, event}
  def parse_event(event) do
    err = %{
      reason: "Unexpected event",
      content: event,
    }
    {:error, err}
  end

  def validate_json(%__MODULE__{} = parsed) do
    parsed
  end

end