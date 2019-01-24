defmodule ServerSentEvent.PullProducer do
  @moduledoc """
  A GenStage Producer responsible for pulling data and turning it into fake ServerSentEvents.
  """
  use GenStage
  import StageHelpers
  require Logger

  # Client functions
  def start_link(args) do
    url = Keyword.fetch!(args, :url)
    GenStage.start_link(__MODULE__, url, start_link_opts(args))
  end

  # Server functions
  defstruct [:url, started?: false, send_after: 10_000]

  def init(url) do
    state = %__MODULE__{url: url}
    {:producer, state}
  end

  def handle_info(:connect, state) do
    url = compute_url(state)
    Logger.debug(fn -> "#{__MODULE__} requesting #{url}" end)

    events =
      with {:ok, %{status_code: 200, body: body}} <-
             HTTPoison.get(url, [], hackney: [follow_redirect: true]) do
        iodata = [
          ~s({"data":),
          body,
          ~s(})
        ]

        [%ServerSentEvent{data: iodata}]
      else
        reason ->
          Logger.error(fn -> "#{__MODULE__} HTTP error: #{inspect(reason)}" end)
          []
      end

    Process.send_after(self(), :connect, state.send_after)
    {:noreply, events, state}
  end

  def handle_demand(_demand, %{started?: false} = state) do
    send(self(), :connect)
    {:noreply, [], %{state | started?: true}}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  defp compute_url(%{url: {m, f, a}}) do
    apply(m, f, a)
  end

  defp compute_url(%{url: url}) when is_binary(url) do
    url
  end
end
