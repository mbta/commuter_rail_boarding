ExUnit.start()

ExUnit.configure(capture_log: true)

defmodule TestHelpers do
  defmacro match_any?(pattern, collection) do
    quote do
      Enum.any?(unquote(collection), fn item ->
        case item do
          unquote(pattern) -> true
          _ -> false
        end
      end)
    end
  end
end
