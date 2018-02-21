defmodule TrainLoc.Input.ServerSentEvent do
  @moduledoc """
  A single ServerSentEvent (SSE) from a server.

  The SSE protocol is defined by the W3C:
  https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream
  """

  alias TrainLoc.Input.ServerSentEvent
  alias TrainLoc.Input.ServerSentEvent.BlockParser

  defstruct [
    event: "message",
    data:  "",
  ]

  @type t :: %__MODULE__{
    event: String.t,
    data: String.t,
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

  iex> TrainLoc.Input.ServerSentEvent.from_string("event: put\\rdata:123\\r\\ndata: 456\\n")
  {:ok, %TrainLoc.Input.ServerSentEvent{event: "put", data: "123\\n456\\n"}}

  iex> TrainLoc.Input.ServerSentEvent.from_string(":comment\\ndata:  short\\nignored: field")
  {:error, %{expected: ["put", "message", "keep-alive", "auth_revoked", "cancel"], got: "", reason: "Unexpected event type"}}
  """
  def from_string(string) do
    sse = BlockParser.parse(string)
    case validate(sse) do
      :ok ->
        {:ok, sse}
      {:error, _} = err ->
        err
    end
  end

  def validate(%ServerSentEvent{event: event}) when event in @event_types do
    :ok
  end
  def validate(%ServerSentEvent{event: invalid_event}) do
    err = %{
      expected: @event_types,
      got: invalid_event,
      reason: "Unexpected event type",
    }
    {:error, err}
  end

end
