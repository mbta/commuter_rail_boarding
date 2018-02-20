defmodule TrainLoc.Input.ServerSentEvent do
  alias TrainLoc.Input.ServerSentEvent.Block
  @moduledoc """
  A single ServerSentEvent (SSE) from a server.

  The SSE protocol is defined by the W3C:
  https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream
  """
  defstruct [
    event:            "message",
    data:             "",
  ]

  @type t :: %__MODULE__{
    event: String.t,
    data: String.t,
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
    case Block.parse(string) do
      {:ok, block} ->
        {:ok, Block.to_server_sent_event(block)}
      {:error, _} = err ->
        err
    end
  end


end
