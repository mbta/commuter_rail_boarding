defmodule TrainLoc.IntegrationTest.Scenarios.OneMinute do
  @moduledoc """
  This module contains the necessary data for running an integration test mocking up one minute of
  messages from the API data source.
  """

  import TrainLoc.Utilities.ConfigHelpers

  @doc """
  This function returns a list of mock API message batches.
  Each batch is a list of mock message strings that will be sent together
  """
  def test_messages do
    # using vehicles 0, 1533-1637, and 4043440397
    [
      [
        "event: put\ndata:{\"path\":\"/\",\"data\":{\"processResults\":{\"date\":\"January 29, 2018 2:23:00 PM\",\"results\":16},\"results\":{\"0\":{\"fix\":0,\"heading\":0,\"latitude\":0,\"longitude\":0,\"routename\":\" \",\"speed\":0,\"updatetime\":0,\"vehicleid\":0,\"workid\":0},\"1533\":{\"fix\":1,\"heading\":0,\"latitude\":4224005,\"longitude\":-7113007,\"routename\":\"\",\"speed\":0,\"updatetime\":1516338396,\"vehicleid\":1533,\"workid\":0},\"1625\":{\"fix\":1,\"heading\":0,\"latitude\":4237393,\"longitude\":-7107462,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235765,\"vehicleid\":1625,\"workid\":0},\"1626\":{\"fix\":1,\"heading\":0,\"latitude\":4237433,\"longitude\":-7107749,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235765,\"vehicleid\":1626,\"workid\":0},\"1627\":{\"fix\":1,\"heading\":279,\"latitude\":4237435,\"longitude\":-7107744,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235751,\"vehicleid\":1627,\"workid\":0},\"1628\":{\"fix\":6,\"heading\":318,\"latitude\":4236698,\"longitude\":-7106314,\"routename\":\"168\",\"speed\":0,\"updatetime\":1517235768,\"vehicleid\":1628,\"workid\":402},\"1629\":{\"fix\":1,\"heading\":169,\"latitude\":4236763,\"longitude\":-7106262,\"routename\":\"214\",\"speed\":0,\"updatetime\":1517235757,\"vehicleid\":1629,\"workid\":300},\"1630\":{\"fix\":1,\"heading\":0,\"latitude\":4237415,\"longitude\":-7107522,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235767,\"vehicleid\":1630,\"workid\":0},\"1631\":{\"fix\":6,\"heading\":318,\"latitude\":4236713,\"longitude\":-7106332,\"routename\":\"324\",\"speed\":0,\"updatetime\":1517235509,\"vehicleid\":1631,\"workid\":200},\"1632\":{\"fix\":1,\"heading\":281,\"latitude\":4237389,\"longitude\":-7107494,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235771,\"vehicleid\":1632,\"workid\":0},\"1633\":{\"fix\":1,\"heading\":247,\"latitude\":4256256,\"longitude\":-7086808,\"routename\":\"116\",\"speed\":24,\"updatetime\":1517235752,\"vehicleid\":1633,\"workid\":104},\"1634\":{\"fix\":1,\"heading\":0,\"latitude\":4237449,\"longitude\":-7107984,\"routename\":\"\",\"speed\":0,\"updatetime\":1517199973,\"vehicleid\":1634,\"workid\":0},\"1635\":{\"fix\":1,\"heading\":75,\"latitude\":4237544,\"longitude\":-7107501,\"routename\":\"\",\"speed\":0,\"updatetime\":1453308912,\"vehicleid\":1635,\"workid\":0},\"1636\":{\"fix\":1,\"heading\":331,\"latitude\":4240295,\"longitude\":-7111302,\"routename\":\"321\",\"speed\":28,\"updatetime\":1517235775,\"vehicleid\":1636,\"workid\":200},\"1637\":{\"fix\":1,\"heading\":123,\"latitude\":4237441,\"longitude\":-7107523,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235745,\"vehicleid\":1637,\"workid\":0},\"4043440397\":{\"fix\":0,\"heading\":0,\"latitude\":0,\"longitude\":0,\"routename\":\" \",\"speed\":0,\"updatetime\":0,\"vehicleid\":4043440397,\"workid\":0}}}}\n\n"
      ],
      [
        "event: put\ndata:{\"path\":\"/\",\"data\":null}\n\n" <>
          "event: put\ndata:{\"path\":\"/results/0\",\"data\":{\"fix\":0,\"heading\":0,\"latitude\":0,\"longitude\":0,\"routename\":\" \",\"speed\":0,\"updatetime\":0,\"vehicleid\":0,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1533\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4224005,\"longitude\":-7113007,\"routename\":\"\",\"speed\":0,\"updatetime\":1516338396,\"vehicleid\":1533,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1625\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237393,\"longitude\":-7107462,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235779,\"vehicleid\":1625,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1626\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237433,\"longitude\":-7107749,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235780,\"vehicleid\":1626,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1627\",\"data\":{\"fix\":1,\"heading\":279,\"latitude\":4237435,\"longitude\":-7107744,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235782,\"vehicleid\":1627,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1628\",\"data\":{\"fix\":6,\"heading\":318,\"latitude\":4236698,\"longitude\":-7106314,\"routename\":\"168\",\"speed\":0,\"updatetime\":1517235768,\"vehicleid\":1628,\"workid\":402}}\n\n" <>
          "event: put\ndata:{\"path\":\"/results/1629\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4236691,\"longitude\":-7106299,\"routename\":\"214\",\"speed\":1,\"updatetime\":1517235787,\"vehicleid\":1629,\"workid\":300}}\n\n" <>
          "event: put\ndata:{\"path\":\"/results/1630\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237415,\"longitude\":-7107522,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235781,\"vehicleid\":1630,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1631\",\"data\":{\"fix\":6,\"heading\":318,\"latitude\":4236713,\"longitude\":-7106332,\"routename\":\"324\",\"speed\":0,\"updatetime\":1517235525,\"vehicleid\":1631,\"workid\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1632\",\"data\":{\"fix\":1,\"heading\":281,\"latitude\":4237389,\"longitude\":-7107494,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235771,\"vehicleid\":1632,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1633\",\"data\":{\"fix\":1,\"heading\":246,\"latitude\":4256209,\"longitude\":-7086955,\"routename\":\"116\",\"speed\":0,\"updatetime\":1517235783,\"vehicleid\":1633,\"workid\":104}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1634\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237449,\"longitude\":-7107984,\"routename\":\"\",\"speed\":0,\"updatetime\":1517199973,\"vehicleid\":1634,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1635\",\"data\":{\"fix\":1,\"heading\":75,\"latitude\":4237544,\"longitude\":-7107501,\"routename\":\"\",\"speed\":0,\"updatetime\":1453308912,\"vehicleid\":1635,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1636\",\"data\":{\"fix\":1,\"heading\":331,\"latitude\":4240295,\"longitude\":-7111302,\"routename\":\"321\",\"speed\":28,\"updatetime\":1517235775,\"vehicleid\":1636,\"workid\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1637\",\"data\":{\"fix\":1,\"heading\":123,\"latitude\":4237441,\"longitude\":-7107523,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235775,\"vehicleid\":1637,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/4043440397\",\"data\":{\"fix\":0,\"heading\":0,\"latitude\":0,\"longitude\":0,\"routename\":\" \",\"speed\":0,\"updatetime\":0,\"vehicleid\":4043440397,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/processResults\",\"data\":{\"date\":\"January 29, 2018 2:23:15 PM\",\"results\":16}}\n\n"
      ],
      [
        "event: put\ndata:{\"path\":\"/\",\"data\":null}\n\n",
        "event: put\ndata:{\"path\":\"/results/0\",\"data\":{\"fix\":0,\"heading\":0,\"latitude\":0,\"longitude\":0,\"routename\":\" \",\"speed\":0,\"updatetime\":0,\"vehicleid\":0,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1533\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4224005,\"longitude\":-7113007,\"routename\":\"\",\"speed\":0,\"updatetime\":1516338396,\"vehicleid\":1533,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1625\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237393,\"longitude\":-7107462,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235795,\"vehicleid\":1625,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1626\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237433,\"longitude\":-7107749,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235795,\"vehicleid\":1626,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1627\",\"data\":{\"fix\":1,\"heading\":279,\"latitude\":4237435,\"longitude\":-7107744,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235782,\"vehicleid\":1627,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1628\",\"data\":{\"fix\":6,\"heading\":318,\"latitude\":4236698,\"longitude\":-7106314,\"routename\":\"168\",\"speed\":0,\"updatetime\":1517235798,\"vehicleid\":1628,\"workid\":402}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1629\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4236691,\"longitude\":-7106299,\"routename\":\"214\",\"speed\":1,\"updatetime\":1517235787,\"vehicleid\":1629,\"workid\":300}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1630\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237415,\"longitude\":-7107522,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235797,\"vehicleid\":1630,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1631\",\"data\":{\"fix\":6,\"heading\":318,\"latitude\":4236713,\"longitude\":-7106332,\"routename\":\"324\",\"speed\":0,\"updatetime\":1517235539,\"vehicleid\":1631,\"workid\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1632\",\"data\":{\"fix\":1,\"heading\":281,\"latitude\":4237389,\"longitude\":-7107494,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235801,\"vehicleid\":1632,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1633\",\"data\":{\"fix\":1,\"heading\":246,\"latitude\":4256209,\"longitude\":-7086955,\"routename\":\"116\",\"speed\":0,\"updatetime\":1517235783,\"vehicleid\":1633,\"workid\":104}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1634\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237449,\"longitude\":-7107984,\"routename\":\"\",\"speed\":0,\"updatetime\":1517199973,\"vehicleid\":1634,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1635\",\"data\":{\"fix\":1,\"heading\":75,\"latitude\":4237544,\"longitude\":-7107501,\"routename\":\"\",\"speed\":0,\"updatetime\":1453308912,\"vehicleid\":1635,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1636\",\"data\":{\"fix\":1,\"heading\":331,\"latitude\":4240607,\"longitude\":-7111536,\"routename\":\"321\",\"speed\":30,\"updatetime\":1517235805,\"vehicleid\":1636,\"workid\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1637\",\"data\":{\"fix\":1,\"heading\":123,\"latitude\":4237442,\"longitude\":-7107525,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235805,\"vehicleid\":1637,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/4043440397\",\"data\":{\"fix\":0,\"heading\":0,\"latitude\":0,\"longitude\":0,\"routename\":\" \",\"speed\":0,\"updatetime\":0,\"vehicleid\":4043440397,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/processResults\",\"data\":{\"date\":\"January 29, 2018 2:23:30 PM\",\"results\":16}}\n\n"
      ],
      [
        "event: put\ndata:{\"path\":\"/\",\"data\":null}\n\n",
        "event: put\ndata:{\"path\":\"/results/1533\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4224005,\"longitude\":-7113007,\"routename\":\"\",\"speed\":0,\"updatetime\":1516338396,\"vehicleid\":1533,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1625\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237393,\"longitude\":-7107462,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235810,\"vehicleid\":1625,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1626\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237433,\"longitude\":-7107749,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235810,\"vehicleid\":1626,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1627\",\"data\":{\"fix\":1,\"heading\":279,\"latitude\":4237435,\"longitude\":-7107744,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235811,\"vehicleid\":1627,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1628\",\"data\":{\"fix\":6,\"heading\":318,\"latitude\":4236698,\"longitude\":-7106314,\"routename\":\"168\",\"speed\":0,\"updatetime\":1517235798,\"vehicleid\":1628,\"workid\":402}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1629\",\"data\":{\"fix\":1,\"heading\":104,\"latitude\":4236702,\"longitude\":-7106286,\"routename\":\"214\",\"speed\":2,\"updatetime\":1517235817,\"vehicleid\":1629,\"workid\":300}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1630\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237415,\"longitude\":-7107522,\"routename\":\"\",\"speed\":0,\"updatetime\":1517235811,\"vehicleid\":1630,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1631\",\"data\":{\"fix\":6,\"heading\":318,\"latitude\":4236713,\"longitude\":-7106332,\"routename\":\"324\",\"speed\":0,\"updatetime\":1517235555,\"vehicleid\":1631,\"workid\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1632\",\"data\":{\"fix\":1,\"heading\":281,\"latitude\":4237389,\"longitude\":-7107494,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235801,\"vehicleid\":1632,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1633\",\"data\":{\"fix\":1,\"heading\":246,\"latitude\":4256180,\"longitude\":-7087048,\"routename\":\"116\",\"speed\":19,\"updatetime\":1517235813,\"vehicleid\":1633,\"workid\":104}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1634\",\"data\":{\"fix\":1,\"heading\":0,\"latitude\":4237449,\"longitude\":-7107984,\"routename\":\"\",\"speed\":0,\"updatetime\":1517199973,\"vehicleid\":1634,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1635\",\"data\":{\"fix\":1,\"heading\":75,\"latitude\":4237544,\"longitude\":-7107501,\"routename\":\"\",\"speed\":0,\"updatetime\":1453308912,\"vehicleid\":1635,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1636\",\"data\":{\"fix\":1,\"heading\":331,\"latitude\":4240607,\"longitude\":-7111536,\"routename\":\"321\",\"speed\":30,\"updatetime\":1517235805,\"vehicleid\":1636,\"workid\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1637\",\"data\":{\"fix\":1,\"heading\":123,\"latitude\":4237442,\"longitude\":-7107525,\"routename\":\"9999\",\"speed\":0,\"updatetime\":1517235805,\"vehicleid\":1637,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/4043440397\",\"data\":{\"fix\":0,\"heading\":0,\"latitude\":0,\"longitude\":0,\"routename\":\" \",\"speed\":0,\"updatetime\":0,\"vehicleid\":4043440397,\"workid\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/processResults\",\"data\":{\"date\":\"January 29, 2018 2:23:45 PM\",\"results\":16}}\n\n"
      ]
    ]
  end

  @doc """
  This is the expected return value of `TrainLoc.Vehicles.State.all_vehicles/0` after processing the above messages
  """
  def expected_vehicle_state do
    time_format = config(:time_format)

    [
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 0,
        latitude: 42.37393,
        longitude: -71.07462,
        trip: "0",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:30 America/New_York", time_format),
        vehicle_id: 1625,
        block: "0"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 0,
        latitude: 42.37433,
        longitude: -71.07749,
        trip: "0",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:30 America/New_York", time_format),
        vehicle_id: 1626,
        block: "0"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 279,
        latitude: 42.37435,
        longitude: -71.07744,
        trip: "9999",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:31 America/New_York", time_format),
        vehicle_id: 1627,
        block: "0"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 6,
        heading: 318,
        latitude: 42.36698,
        longitude: -71.06314,
        trip: "168",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:18 America/New_York", time_format),
        vehicle_id: 1628,
        block: "402"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 104,
        latitude: 42.36702,
        longitude: -71.06286,
        trip: "214",
        speed: 2,
        timestamp: Timex.parse!("2018-01-29 14:23:37 America/New_York", time_format),
        vehicle_id: 1629,
        block: "300"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 0,
        latitude: 42.37415,
        longitude: -71.07522,
        trip: "0",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:31 America/New_York", time_format),
        vehicle_id: 1630,
        block: "0"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 6,
        heading: 318,
        latitude: 42.36713,
        longitude: -71.06332,
        trip: "324",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:19:15 America/New_York", time_format),
        vehicle_id: 1631,
        block: "200"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 281,
        latitude: 42.37389,
        longitude: -71.07494,
        trip: "9999",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:21 America/New_York", time_format),
        vehicle_id: 1632,
        block: "0"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 246,
        latitude: 42.56180,
        longitude: -70.87048,
        trip: "116",
        speed: 19,
        timestamp: Timex.parse!("2018-01-29 14:23:33 America/New_York", time_format),
        vehicle_id: 1633,
        block: "104"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 331,
        latitude: 42.40607,
        longitude: -71.11536,
        trip: "321",
        speed: 30,
        timestamp: Timex.parse!("2018-01-29 14:23:25 America/New_York", time_format),
        vehicle_id: 1636,
        block: "200"
      },
      %TrainLoc.Vehicles.Vehicle{
        fix: 1,
        heading: 123,
        latitude: 42.37442,
        longitude: -71.07525,
        trip: "9999",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:25 America/New_York", time_format),
        vehicle_id: 1637,
        block: "0"
      }
    ]
  end

  @doc """
  This is the expected return value of `TrainLoc.Conflicts.State.all_conflicts/0` after processing the above messages
  """
  def expected_conflict_state do
    TrainLoc.Conflicts.Conflicts.new([
      %TrainLoc.Conflicts.Conflict{
        assign_id: "200",
        assign_type: :block,
        service_date: ~D[2018-01-29],
        vehicles: [1631, 1636]
      }
    ])
  end
end
