defmodule TrainLoc.Input.ServerSentEvent do
  @moduledoc """
  A single ServerSentEvent (SSE) from a server.

  The SSE protocol is defined by the W3C:
  https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream

  Each binary block is parsed into a ServerSentEvent struct then validated.
  """

  alias TrainLoc.Input.ServerSentEvent.BlockParser

  defstruct [
    event: "message",
    data:  "",
  ]

  @type t :: %__MODULE__{
    event: String.t,
    data: String.t,
  }

  @doc """
  Parse a UTF-8 string into a struct.

  Expects a full SSE block.

  iex> TrainLoc.Input.ServerSentEvent.from_string("event: put\\rdata:123\\r\\ndata: 456\\n")
  %TrainLoc.Input.ServerSentEvent{event: "put", data: "123\\n456\\n"}

  iex> TrainLoc.Input.ServerSentEvent.from_string(":comment\\ndata:  short\\nignored: field")
  %TrainLoc.Input.ServerSentEvent{data: " short\n", event: ""}
  """
  def from_string(string) do
    BlockParser.parse(string)
  end

end
