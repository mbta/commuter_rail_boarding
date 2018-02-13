defmodule TrainLoc.Logging do
  require Logger

  @bare_levels [
    :info,
    :warn,
    :error,
    :debug,
  ]
  
  def debug(message), do: log(:debug, message)
  def info(message),  do: log(:info, message)
  def warn(message),  do: log(:warn, message)
  def error(message), do: log(:error, message)

  # TODO: specs for log/2

  @doc """
  log/2 takes as the first argument:
    + a 0 arity function (see below for return types)
    + a struct
    + a map
  log/2 takes as the second argument
  and a level.


  Functions must return an iolist (preferred for speed) or a binary.
  """
  # def log(func, :debug) when is_function(func, 0) do
  #   # special case for Logger.bare_log
  #   Logger.debug(func)
  # end
  def log(level, %module{} = struct_thing) do
    message = 
      struct_thing
      |> Map.from_struct # removes :__struct__ field
      |> Map.put(:_module, module |> pretty_module)
    log(level, message)
  end
  def log(level, params) when is_map(params) do
    message = 
      fn ->
        iolist = 
          params
          |> Map.drop([:title, :__struct__]) # handled in format_title
          |> Enum.reduce([], fn ({key, value}, acc) ->
            [to_string(key), "=", to_value(value), " " | acc ]
          end)
        [ format_title(params) | iolist ]
      end
    log(level, message)
  end
  def log(level, func) when is_function(func, 0) and level in @bare_levels do
    # this is our base case.
    # According to the Logger documents for increased speed,
    # functions can be passed to the Logger module when
    # an expensive computation is involved.
    # this works because logger calls are marcos that might not
    # get evaluated at runtime depending on the log level.
    Logger.log(level, func)
  end


  defp to_value(str) when is_binary(str) do
    inspect(str) # add quotes
  end
  defp to_value(x) do
    to_string(x) # safe for iolist
  end

  defp format_title(%{title: title}) do
    [to_string(title), " - "]
  end
  defp format_title(_) do
    ""
  end

  defp pretty_module(module) do
    module
    |> Module.split
    |> Enum.join(".")
  end

end