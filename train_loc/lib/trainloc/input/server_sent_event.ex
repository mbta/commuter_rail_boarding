defmodule TrainLoc.Input.ServerSentEvent do
  alias TrainLoc.Input.ServerSentEvent
  @moduledoc """
  A single ServerSentEvent (SSE) from a server.

  The SSE protocol is defined by the W3C:
  https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream
  """
  defstruct [
    event:    "message",
    data:     "",
    binary:   "",
    json:     nil,
    vehicles: [],
    errors:   [], #if everything is successful this is an empty list.
    date:     nil,
  ]

  # @type event_type :: "put" | "message" | "keep-alive" | "auth_revoked" | "cancel"

  @type t :: %__MODULE__{
    event: String.t,
    data: String.t
  }

  @event_types [
    "put",
    "message",
    "keep-alive",
    "auth_revoked",
    "cancel"
  ]

  @doc """
  Parse a UTF-8 string into a struct.

  Expects a full SSE block.

  iex> ServerSentEvent.from_string("event: put\\rdata:123\\r\\ndata: 456\\n")
  %ServerSentEvent{event: "put", binary: "123\\n456\\n"}

  iex> ServerSentEvent.from_string(":comment\\ndata:  short\\nignored: field")
  %ServerSentEvent{event: "message", binary: " short\\n"}
  """
  def from_string(string) do
    line = ServerSentEvent.LineParser.parse(string)
    %ServerSentEvent{
      event: line.event,
      binary: line.binary,
    }
    |> validate_event
    |> parse_json
    |> parse_vehicle
    |> remove_MEEEEE
  end

  def remove_MEEEEE(sse) do
    %{ sse | data: sse.json }
  end

  defp add_error(%ServerSentEvent{} = sse, errors) when is_list(errors) do
    %{ sse | errors: sse.errors ++ errors}
  end
  defp add_error(%ServerSentEvent{} = sse, err) do
    add_error(sse, [err])
  end

  def validate_event(%ServerSentEvent{} = sse) do
    case sse.event do
      type when type in @event_types ->
        sse
      invalid_type ->
        err = %{
          expected: @event_types,
          got: invalid_type,
          reason: "Unexpected event type",
        }
        add_error(sse, err)
    end
  end

  def parse_json(%ServerSentEvent{} = sse) do
    case ServerSentEvent.JsonParser.parse(sse.binary) do
      {:ok, %{date: date, vehicles_json: vehicles_json}} ->
        %{ sse | json: vehicles_json, date: date }
      {:error, reason} ->
        add_error(sse, %{reason: reason})
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

  def parse_vehicle(%ServerSentEvent{} = sse) do
    {vehicles, errors} = ServerSentEvent.VehicleParser.parse(sse.json)
    %{ sse |
      vehicles: sse.vehicles ++ vehicles,
      errors: sse.errors ++ errors,
    }
  end


end
