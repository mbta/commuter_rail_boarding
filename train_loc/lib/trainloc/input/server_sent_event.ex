defmodule TrainLoc.Input.ServerSentEvent do
  @moduledoc """
  A single ServerSentEvent (SSE) from a server.

  The SSE protocol is defined by the W3C:
  https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream
  """
  defstruct [
    event: "message",
    data: ""
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
  %ServerSentEvent{event: "put", data: "123\\n456\\n"}

  iex> ServerSentEvent.from_string(":comment\\ndata:  short\\nignored: field")
  %ServerSentEvent{event: "message", data: " short\\n"}
  """
  def from_string(string) do
    string
    |> String.split(~r/\r|\r\n|\n/, trim: true)
    |> Enum.reduce(%{event: "", data: ""}, &include_line/2)
    |> parse_line()
  end

  defp include_line(":" <> _, acc) do
    # comment
    acc
  end
  defp include_line("event:" <> rest, acc) do
    # event, can only be one
    %{acc | event: trim_one_space(rest)}
  end
  defp include_line("data:" <> rest, acc) do
    # data, gets accumulated separated by newlines
    %{acc | data: add_data(acc.data, trim_one_space(rest))}
  end
  defp include_line(_, acc) do
    # ignored
    acc
  end

  def parse_line(line) do
    with \
      {:ok, event} <- parse_event(line.event),
      {:ok, data} <- parse_data(line.data)
    do
      {:ok, %__MODULE__{
        event: event,
        data: data,
      }}
    else
      {:error, _} = error -> error
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

  def parse_data(data) when is_binary(data) do
    case Poison.decode(data) do
      {:ok, json} ->
        # parse_json(json)
        {:ok, json}
      _ ->
        {:error, :invalid_json}
    end
  end

  def parse_json(%{"data" => data}) do
    parse_json(data)
  end
  def parse_json(%{"vehicleid" => _} = vehicle) do
  end

  defp trim_one_space(" " <> rest), do: rest
  defp trim_one_space(data), do: data

  defp add_data(first, second) do
    first <> second <> "\n"
  end
end
