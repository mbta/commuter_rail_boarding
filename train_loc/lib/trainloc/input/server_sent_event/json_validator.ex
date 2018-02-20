defmodule TrainLoc.Input.ServerSentEvent.JsonValidator do

  def validate(json) when is_map(json) do
    with \
      {:ok, fix}        <- fetch(json, "fix"),
      {:ok, heading}    <- fetch(json, "heading"),
      {:ok, latitude}   <- fetch(json, "latitude"),
      {:ok, longitude}  <- fetch(json, "longitude"),
      {:ok, speed}      <- fetch(json, "speed"),
      {:ok, updatetime} <- fetch(json, "updatetime"),
      {:ok, vehicleid}  <- fetch(json, "vehicleid"),
      {:ok, workid}     <- fetch(json, "workid"),
      {:ok, routename}  <- fetch(json, "routename"),
      :ok               <- ensure_integer(fix, "fix"),
      :ok               <- ensure_integer(heading, "heading"),
      :ok               <- ensure_integer(latitude, "latitude"),
      :ok               <- ensure_integer(longitude, "longitude"),
      :ok               <- ensure_integer(speed, "speed"),
      :ok               <- ensure_integer(updatetime, "updatetime"),
      :ok               <- ensure_integer(vehicleid, "vehicleid"),
      :ok               <- ensure_integer(workid, "workid"),
      :ok               <- ensure_string(routename, "routename")
    do
      :ok
    else
      {:error, {:missing, key}} ->
        {:error, missing_json_key(key)}
      {:error, {:not_integer, key}} ->
        {:error, must_be_integer(key)}
      {:error, {:not_string, key}} ->
        {:error, must_be_string(key)}
    end
  end
  def validate(_) do
    {:error, :invalid_json}
  end

  defp missing_json_key(key) do
    "JSON key '#{key}' was missing."
  end

  defp must_be_integer(key) do
    "JSON key '#{key}' must be an integer."
  end

  defp must_be_string(key) do
    "JSON key '#{key}' must be a string."
  end

  def fetch(params, key) when is_map(params) do
    case Map.fetch(params, key) do
      {:ok, _} = found -> found
      :error -> {:error, {:missing, key}}
    end
  end

  def ensure_integer(value, _) when is_integer(value) do
    :ok
  end
  def ensure_integer(_, key) do
    {:error, {:not_integer, key}}
  end

  def ensure_string(value, _key) when is_binary(value) do
    :ok
  end
  def ensure_string(_value, key) do
    {:error, {:not_string, key}}
  end
end
