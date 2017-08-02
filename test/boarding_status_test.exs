defmodule BoardingStatusTest do
  @moduledoc false
  use ExUnit.Case
  import BoardingStatus

  @moduletag :capture_log

  setup_all do
    Application.ensure_all_started(:httpoison)
    {:ok, _pid} = TripCache.start_link()
    :ok
  end

  describe "from_firebase/1" do
    test "returns {:ok, t} or :error for all items from fixture" do
      results = "test/fixtures/firebase.json"
      |> File.read!
      |> Poison.decode!
      |> Map.get("results")

      refute results == []
      for result <- results do
        parsed =
          case from_firebase(result) do
            {:ok, %BoardingStatus{}} -> :ok
            :error -> :ok
            unknown -> {:unknown, unknown}
          end
        assert parsed == :ok
      end
    end
  end
end
