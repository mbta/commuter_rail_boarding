defmodule TrainLoc.Input.ServerSentEvent do
  alias TrainLoc.Input.ServerSentEvent
  alias TrainLoc.Input.ServerSentEvent.Parser
  @moduledoc """
  A single ServerSentEvent (SSE) from a server.

  The SSE protocol is defined by the W3C:
  https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream
  """
  defstruct [
    event:            "message",
    data:             [],
    date:             nil,
  ]

  # @type event_type :: "put" | "message" | "keep-alive" | "auth_revoked" | "cancel"

  @type t :: %__MODULE__{
    event: String.t,
    data: [map],
    date: String.t | nil,
  }

  @doc """
  Parse a UTF-8 string into a struct.

  Expects a full SSE block.

  iex> ServerSentEvent.from_string("event: put\\rdata:123\\r\\ndata: 456\\n")
  %ServerSentEvent{event: "put", binary: "123\\n456\\n"}

  iex> ServerSentEvent.from_string(":comment\\ndata:  short\\nignored: field")
  %ServerSentEvent{event: "message", binary: " short\\n"}
  """
  def from_string(string) do
    parser_struct = Parser.parse(string)
    case parser_struct.errors do
      [] ->
        {:ok, from_parser_struct(parser_struct)}
      errors ->
        {:error, errors}
    end
  end

  def from_parser_struct(parser) do
    %ServerSentEvent{
      event:    parser.event,
      date:     parser.date,
      data:     parser.json,
    }
  end

end
