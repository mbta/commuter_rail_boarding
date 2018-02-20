# defmodule TrainLoc.Vehicles.Schema do
#   @moduledoc """
#   This schema is for validating the Vehicle parameters.
#   """
#   use Ecto.Schema
#   alias Ecto.Changeset
#   alias TrainLoc.Vehicles.{Schema, Vehicle}


#   schema "abstract vehicle" do
#     field :vehicle_id, :integer # non_neg_integer,
#     field :timestamp,  :utc_datetime # DateTime.t,
#     field :block,      :string  # non_neg_integer,
#     field :trip,       :string  #String.t,
#     field :latitude,   :float
#     field :longitude,  :float
#     field :heading,    :integer #0..359,
#     field :speed,      :integer #non_neg_integer,
#     field :fix,        :integer #0..9
#   end

#   @allowed_fields [
#     :vehicle_id,
#     :timestamp,
#     :block,
#     :trip,
#     :latitude,
#     :longitude,
#     :heading,
#     :speed,
#     :fix,
#   ]

#   def changeset(model, params \\ %{}) do
#     model
#     |> Changeset.cast(params, @allowed_fields)
#     |> ensure_new_york_datetime
#     |> Changeset.validate_required(@allowed_fields)
#     |> Changeset.validate_number(:vehicle_id, greater_than_or_equal_to: 0)
#     |> Changeset.validate_number(:block, greater_than_or_equal_to: 0)
#     |> Changeset.validate_inclusion(:heading, 0..359)
#     |> Changeset.validate_number(:speed, greater_than_or_equal_to: 0)
#     |> Changeset.validate_inclusion(:fix, 0..9)
#   end

#   # defp validate_datetime(%Changeset{} = cs, field, opts \\ []) do
#   #   value = Changeset.get_change(cs, field)
#   #   message =  Keyword.get(opts, :message, "Invalid DateTime")
#   #   case value do
#   #     %NaiveDateTime{} ->
#   #       cs
#   #     _ ->
#   #       Changeset.add_error(cs, field, message)
#   #   end
#   # end

#   def from_keolis_json(%{} = veh_data) do
#     changes = Vehicle.to_changes(veh_data)
#     %Schema{}
#     |> changeset(changes)
#     |> case do
#       %{valid?: true} = cs ->
#         {:ok, Changeset.apply_changes(cs)}
#       %{valid?: false} = cs ->
#         {:error, process_errors(cs)}
#     end
#   end

#   def ensure_new_york_datetime(%Changeset{changes: %{timestamp: %DateTime{} = utc_timestamp}} = cs) do
#     new_york_datetime = Timex.Timezone.convert(utc_timestamp, "America/New_York")
#     Changeset.put_change(cs, :timestamp, new_york_datetime)
#   end
#   def ensure_new_york_datetime(cs) do
#     cs
#   end

#   def to_vehicle_struct(%Schema{} = valid_schema) do
#     struct(Vehicle, Map.from_struct(valid_schema))
#   end

#   defp process_errors(%Changeset{} = cs) do
#     process_errors(cs, cs.errors)
#   end
#   defp process_errors(cs, errors) when is_list(errors) do
#     errors
#     |> Enum.map(fn field_error -> process_errors(cs, field_error) end)
#   end
#   defp process_errors(cs, {key, {reason, validations}}) do
#     %{
#       field: key,
#       got: Changeset.get_change(cs, key),
#       reason: reason,
#       validations: validations |> Keyword.values(),
#     }
#   end


# end
