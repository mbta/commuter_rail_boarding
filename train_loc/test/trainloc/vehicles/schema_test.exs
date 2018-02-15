defmodule TrainLoc.Vehicles.SchemaTest do
  use ExUnit.Case, async: true
  use Timex

  alias TrainLoc.Vehicles.Schema
  import TrainLoc.Utilities.ConfigHelpers

  @valid_timestamp DateTime.utc_now() 
  @valid_changes %{
    block: "602",
    fix: 1,
    heading: 48,
    latitude: 42.28179,
    longitude: -71.15936,
    speed: 14,
    timestamp: @valid_timestamp,
    trip: "612",
    vehicle_id: 1827,
  }
  @unexpected_values %{
    vehicle_id: -1,
    timestamp: nil, # strings, datetimes, and nils only please.
    block: -1,
    trip: :something,
    latitude: :string,
    longitude: :json,
    heading: -10,
    speed: -11,
    fix: -11,
  }

  describe "changeset/2" do
    test "is valid with valid changes" do
      cs = Schema.changeset(%Schema{}, @valid_changes)
      # sanity check for Ecto datetime casting.
      assert %DateTime{} = @valid_changes.timestamp
      assert %DateTime{} = cs.changes.timestamp
      assert %Ecto.Changeset{valid?: true} = cs
    end

    test "is invalid with any field missing" do
      invalid_changes = %{}
      cs = Schema.changeset(%Schema{}, invalid_changes)
      assert %Ecto.Changeset{valid?: false} = cs
    end

    test "is invalid with unexpected values" do
      invalid_changes = @unexpected_values
      cs = Schema.changeset(%Schema{}, invalid_changes)
      assert %Ecto.Changeset{valid?: false} = cs
    end
  end
end