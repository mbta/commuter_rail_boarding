defmodule TrainLoc.Input.ServerSentEvent.Block do
  @moduledoc """
  An module for parsing raw
  server sent event binary blocks.
  """
  alias TrainLoc.Input.ServerSentEvent    
  alias TrainLoc.Input.ServerSentEvent.{
    Block,
    BlockParser,
  }

  defstruct [
    event:    "message",
    binary:   "",
  ]

  @event_types [
    "put",
    "message",
    "keep-alive",
    "auth_revoked",
    "cancel"
  ]

  def parse(string) do
    block_parts = BlockParser.parse(string)
    block = %Block{
      event: block_parts.event,
      binary: block_parts.binary,
    }
    case validate_block(block) do
      :ok ->
        {:ok, block}
      {:error, _} = err ->
        err
    end
  end

  def validate_block(%Block{event: event}) when event in @event_types do
    :ok
  end
  def validate_block(%Block{event: invalid_event}) do
    err = %{
      expected: @event_types,
      got: invalid_event,
      reason: "Unexpected event type",
    }
    {:error, err}
  end

  def to_server_sent_event(%Block{event: event, binary: binary}) do
    %ServerSentEvent{
      event: event,
      data:  binary,
    }
  end

end
