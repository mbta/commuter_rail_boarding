defmodule TrainLoc.IntegrationTest.TimeHelper do
  @moduledoc false

  @doc """
  This is the timestamp from the end of the OneMinute integration test scenario, used to ensure
  that the test messages aren't discarded as stale.
  """
  def test_time do
    1_517_253_825
  end
end
