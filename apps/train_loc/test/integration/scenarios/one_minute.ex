defmodule TrainLoc.IntegrationTest.Scenarios.OneMinute do
  @moduledoc """
  This module contains the necessary data for running an integration test mocking up one minute of
  messages from the API data source.
  """

  alias TrainLoc.Conflicts.{Conflict, Conflicts}
  import TrainLoc.Utilities.ConfigHelpers

  @doc """
  This function returns a list of mock API message batches.
  Each batch is a list of mock message strings that will be sent together
  """
  def test_messages do
    # using vehicles 0, 1509-1637, and 4043440397
    [
      [
        "event: put\ndata:{\"path\":\"/\",\"data\":{\"processResults\":{\"date\":\"January 29, 2018 2:23:00 PM\",\"results\":16},\"results\":" <>
          "{\"0\":{\"Heading\":0,\"ID\":1,\"Latitude\":0,\"Longitude\":0,\"TripID\":0,\"Speed\":0,\"Update Time\":\"1970-01-01T00:00:00.000Z\",\"VehicleID\":0,\"WorkID\":0}," <>
          "\"1509\":{\"Heading\":0,\"ID\":0,\"Latitude\":41.29148,\"Longitude\":-72.92814,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:45.000Z\",\"VehicleID\":1509,\"WorkID\":0}," <>
          "\"1533\":{\"Heading\":0,\"ID\":2,\"Latitude\":42.24005,\"Longitude\":-71.13007,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-19T05:06:36.000Z\",\"VehicleID\":1533,\"WorkID\":0}," <>
          "\"1625\":{\"Heading\":0,\"ID\":3,\"Latitude\":42.37393,\"Longitude\":-71.07462,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:45.000Z\",\"VehicleID\":1625,\"WorkID\":0}," <>
          "\"1626\":{\"Heading\":0,\"ID\":4,\"Latitude\":42.37433,\"Longitude\":-71.07749,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:45.000Z\",\"VehicleID\":1626,\"WorkID\":0}," <>
          "\"1627\":{\"Heading\":279,\"ID\":5,\"Latitude\":42.37435,\"Longitude\":-71.07744,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:31.000Z\",\"VehicleID\":1627,\"WorkID\":0}," <>
          "\"1628\":{\"Heading\":318,\"ID\":6,\"Latitude\":42.36698,\"Longitude\":-71.06314,\"TripID\":168,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:48.000Z\",\"VehicleID\":1628,\"WorkID\":402}," <>
          "\"1629\":{\"Heading\":169,\"ID\":7,\"Latitude\":42.36763,\"Longitude\":-71.06262,\"TripID\":214,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:37.000Z\",\"VehicleID\":1629,\"WorkID\":300}," <>
          "\"1630\":{\"Heading\":0,\"ID\":8,\"Latitude\":42.37415,\"Longitude\":-71.07522,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:47.000Z\",\"VehicleID\":1630,\"WorkID\":0}," <>
          "\"1631\":{\"Heading\":318,\"ID\":9,\"Latitude\":42.36713,\"Longitude\":-71.06332,\"TripID\":324,\"Speed\":0,\"Update Time\":\"2018-01-29T14:18:29.000Z\",\"VehicleID\":1631,\"WorkID\":200}," <>
          "\"1632\":{\"Heading\":281,\"ID\":10,\"Latitude\":42.37389,\"Longitude\":-71.07494,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:51.000Z\",\"VehicleID\":1632,\"WorkID\":0}," <>
          "\"1633\":{\"Heading\":247,\"ID\":11,\"Latitude\":42.56256,\"Longitude\":-70.86808,\"TripID\":116,\"Speed\":24,\"Update Time\":\"2018-01-29T14:22:32.000Z\",\"VehicleID\":1633,\"WorkID\":104}," <>
          "\"1634\":{\"Heading\":0,\"ID\":12,\"Latitude\":42.37449,\"Longitude\":-71.07984,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T04:26:13.000Z\",\"VehicleID\":1634,\"WorkID\":0}," <>
          "\"1635\":{\"Heading\":75,\"ID\":13,\"Latitude\":42.37544,\"Longitude\":-71.07501,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2016-01-20T16:55:12.000Z\",\"VehicleID\":1635,\"WorkID\":0}," <>
          "\"1636\":{\"Heading\":331,\"ID\":14,\"Latitude\":42.40295,\"Longitude\":-71.11302,\"TripID\":321,\"Speed\":28,\"Update Time\":\"2018-01-29T14:22:55.000Z\",\"VehicleID\":1636,\"WorkID\":200}," <>
          "\"1637\":{\"Heading\":123,\"ID\":15,\"Latitude\":42.37441,\"Longitude\":-71.07523,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:25.000Z\",\"VehicleID\":1637,\"WorkID\":0}," <>
          "\"4043440397\":{\"Heading\":0,\"ID\":16,\"Latitude\":0,\"Longitude\":0,\"TripID\":0,\"Speed\":0,\"Update Time\":\"1970-01-01T00:00:00.000Z\",\"VehicleID\":4043440397,\"WorkID\":0}}}}\n\n"
      ],
      [
        "event: put\ndata:{\"path\":\"/\",\"data\":null}\n\n" <>
          "event: put\ndata:{\"path\":\"/results/0\",\"data\":{\"Heading\":0,\"ID\":17,\"Latitude\":0,\"Longitude\":0,\"TripID\":0,\"Speed\":0,\"Update Time\":\"1970-01-01T00:00:00.000Z\",\"VehicleID\":0,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1509\",\"data\":{\"Heading\":0,\"ID\":0,\"Latitude\":41.29148,\"Longitude\":-72.92814,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:59.000Z\",\"VehicleID\":1509,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1533\",\"data\":{\"Heading\":0,\"ID\":18,\"Latitude\":42.24005,\"Longitude\":-71.13007,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-19T05:06:36.000Z\",\"VehicleID\":1533,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1625\",\"data\":{\"Heading\":0,\"ID\":19,\"Latitude\":42.37393,\"Longitude\":-71.07462,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:59.000Z\",\"VehicleID\":1625,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1626\",\"data\":{\"Heading\":0,\"ID\":20,\"Latitude\":42.37433,\"Longitude\":-71.07749,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:00.000Z\",\"VehicleID\":1626,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1627\",\"data\":{\"Heading\":279,\"ID\":21,\"Latitude\":42.37435,\"Longitude\":-71.07744,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:02.000Z\",\"VehicleID\":1627,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1628\",\"data\":{\"Heading\":318,\"ID\":22,\"Latitude\":42.36698,\"Longitude\":-71.06314,\"TripID\":168,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:48.000Z\",\"VehicleID\":1628,\"WorkID\":402}}\n\n" <>
          "event: put\ndata:{\"path\":\"/results/1629\",\"data\":{\"Heading\":0,\"ID\":23,\"Latitude\":42.36691,\"Longitude\":-71.06299,\"TripID\":214,\"Speed\":1,\"Update Time\":\"2018-01-29T14:23:07.000Z\",\"VehicleID\":1629,\"WorkID\":300}}\n\n" <>
          "event: put\ndata:{\"path\":\"/results/1630\",\"data\":{\"Heading\":0,\"ID\":24,\"Latitude\":42.37415,\"Longitude\":-71.07522,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:01.000Z\",\"VehicleID\":1630,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1631\",\"data\":{\"Heading\":318,\"ID\":25,\"Latitude\":42.36713,\"Longitude\":-71.06332,\"TripID\":324,\"Speed\":0,\"Update Time\":\"2018-01-29T14:18:45.000Z\",\"VehicleID\":1631,\"WorkID\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1632\",\"data\":{\"Heading\":281,\"ID\":26,\"Latitude\":42.37389,\"Longitude\":-71.07494,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:51.000Z\",\"VehicleID\":1632,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1633\",\"data\":{\"Heading\":246,\"ID\":27,\"Latitude\":42.56209,\"Longitude\":-70.86955,\"TripID\":116,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:03.000Z\",\"VehicleID\":1633,\"WorkID\":104}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1634\",\"data\":{\"Heading\":0,\"ID\":28,\"Latitude\":42.37449,\"Longitude\":-71.07984,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T04:26:13.000Z\",\"VehicleID\":1634,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1635\",\"data\":{\"Heading\":75,\"ID\":29,\"Latitude\":42.37544,\"Longitude\":-71.07501,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2016-01-20T16:55:12.000Z\",\"VehicleID\":1635,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1636\",\"data\":{\"Heading\":331,\"ID\":30,\"Latitude\":42.40295,\"Longitude\":-71.11302,\"TripID\":321,\"Speed\":28,\"Update Time\":\"2018-01-29T14:22:55.000Z\",\"VehicleID\":1636,\"WorkID\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1637\",\"data\":{\"Heading\":123,\"ID\":31,\"Latitude\":42.37441,\"Longitude\":-71.07523,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:22:55.000Z\",\"VehicleID\":1637,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/4043440397\",\"data\":{\"Heading\":0,\"ID\":32,\"Latitude\":0,\"Longitude\":0,\"TripID\":0,\"Speed\":0,\"Update Time\":\"1970-01-01T00:00:00.000Z\",\"VehicleID\":4043440397,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/processResults\",\"data\":{\"date\":\"January 29, 2018 2:23:15 PM\",\"results\":16}}\n\n"
      ],
      [
        "event: put\ndata:{\"path\":\"/\",\"data\":null}\n\n",
        "event: put\ndata:{\"path\":\"/results/0\",\"data\":{\"Heading\":0,\"ID\":33,\"Latitude\":0,\"Longitude\":0,\"TripID\":0,\"Speed\":0,\"Update Time\":\"1970-01-01T00:00:00.000Z\",\"VehicleID\":0,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1509\",\"data\":{\"Heading\":0,\"ID\":0,\"Latitude\":41.29148,\"Longitude\":-72.92814,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:15.000Z\",\"VehicleID\":1509,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1533\",\"data\":{\"Heading\":0,\"ID\":34,\"Latitude\":42.24005,\"Longitude\":-71.13007,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-19T05:06:36.000Z\",\"VehicleID\":1533,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1625\",\"data\":{\"Heading\":0,\"ID\":35,\"Latitude\":42.37393,\"Longitude\":-71.07462,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:15.000Z\",\"VehicleID\":1625,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1626\",\"data\":{\"Heading\":0,\"ID\":36,\"Latitude\":42.37433,\"Longitude\":-71.07749,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:15.000Z\",\"VehicleID\":1626,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1627\",\"data\":{\"Heading\":279,\"ID\":37,\"Latitude\":42.37435,\"Longitude\":-71.07744,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:02.000Z\",\"VehicleID\":1627,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1628\",\"data\":{\"Heading\":318,\"ID\":38,\"Latitude\":42.36698,\"Longitude\":-71.06314,\"TripID\":168,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:18.000Z\",\"VehicleID\":1628,\"WorkID\":402}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1629\",\"data\":{\"Heading\":0,\"ID\":39,\"Latitude\":42.36691,\"Longitude\":-71.06299,\"TripID\":214,\"Speed\":1,\"Update Time\":\"2018-01-29T14:23:07.000Z\",\"VehicleID\":1629,\"WorkID\":300}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1630\",\"data\":{\"Heading\":0,\"ID\":40,\"Latitude\":42.37415,\"Longitude\":-71.07522,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:17.000Z\",\"VehicleID\":1630,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1631\",\"data\":{\"Heading\":318,\"ID\":41,\"Latitude\":42.36713,\"Longitude\":-71.06332,\"TripID\":324,\"Speed\":0,\"Update Time\":\"2018-01-29T14:18:59.000Z\",\"VehicleID\":1631,\"WorkID\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1632\",\"data\":{\"Heading\":281,\"ID\":42,\"Latitude\":42.37389,\"Longitude\":-71.07494,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:21.000Z\",\"VehicleID\":1632,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1633\",\"data\":{\"Heading\":246,\"ID\":43,\"Latitude\":42.56209,\"Longitude\":-70.86955,\"TripID\":116,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:03.000Z\",\"VehicleID\":1633,\"WorkID\":104}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1634\",\"data\":{\"Heading\":0,\"ID\":44,\"Latitude\":42.37449,\"Longitude\":-71.07984,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T04:26:13.000Z\",\"VehicleID\":1634,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1635\",\"data\":{\"Heading\":75,\"ID\":45,\"Latitude\":42.37544,\"Longitude\":-71.07501,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2016-01-20T16:55:12.000Z\",\"VehicleID\":1635,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1636\",\"data\":{\"Heading\":331,\"ID\":46,\"Latitude\":42.40607,\"Longitude\":-71.11536,\"TripID\":321,\"Speed\":30,\"Update Time\":\"2018-01-29T14:23:25.000Z\",\"VehicleID\":1636,\"WorkID\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1637\",\"data\":{\"Heading\":123,\"ID\":47,\"Latitude\":42.37442,\"Longitude\":-71.07525,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:25.000Z\",\"VehicleID\":1637,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/4043440397\",\"data\":{\"Heading\":0,\"ID\":48,\"Latitude\":0,\"Longitude\":0,\"TripID\":0,\"Speed\":0,\"Update Time\":\"1970-01-01T00:00:00.000Z\",\"VehicleID\":4043440397,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/processResults\",\"data\":{\"date\":\"January 29, 2018 2:23:30 PM\",\"results\":16}}\n\n"
      ],
      [
        "event: put\ndata:{\"path\":\"/\",\"data\":null}\n\n",
        "event: put\ndata:{\"path\":\"/results/1509\",\"data\":{\"Heading\":0,\"ID\":0,\"Latitude\":41.29148,\"Longitude\":-72.92814,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:30.000Z\",\"VehicleID\":1509,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1533\",\"data\":{\"Heading\":0,\"ID\":49,\"Latitude\":42.24005,\"Longitude\":-71.13007,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-19T05:06:36.000Z\",\"VehicleID\":1533,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1625\",\"data\":{\"Heading\":0,\"ID\":50,\"Latitude\":42.37393,\"Longitude\":-71.07462,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:30.000Z\",\"VehicleID\":1625,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1626\",\"data\":{\"Heading\":0,\"ID\":51,\"Latitude\":42.37433,\"Longitude\":-71.07749,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:30.000Z\",\"VehicleID\":1626,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1627\",\"data\":{\"Heading\":279,\"ID\":52,\"Latitude\":42.37435,\"Longitude\":-71.07744,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:31.000Z\",\"VehicleID\":1627,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1628\",\"data\":{\"Heading\":318,\"ID\":53,\"Latitude\":42.36698,\"Longitude\":-71.06314,\"TripID\":168,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:18.000Z\",\"VehicleID\":1628,\"WorkID\":402}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1629\",\"data\":{\"Heading\":104,\"ID\":54,\"Latitude\":42.36702,\"Longitude\":-71.06286,\"TripID\":214,\"Speed\":2,\"Update Time\":\"2018-01-29T14:23:37.000Z\",\"VehicleID\":1629,\"WorkID\":300}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1630\",\"data\":{\"Heading\":0,\"ID\":55,\"Latitude\":42.37415,\"Longitude\":-71.07522,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:31.000Z\",\"VehicleID\":1630,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1631\",\"data\":{\"Heading\":318,\"ID\":56,\"Latitude\":42.36713,\"Longitude\":-71.06332,\"TripID\":324,\"Speed\":0,\"Update Time\":\"2018-01-29T14:19:15.000Z\",\"VehicleID\":1631,\"WorkID\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1632\",\"data\":{\"Heading\":281,\"ID\":57,\"Latitude\":42.37389,\"Longitude\":-71.07494,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:21.000Z\",\"VehicleID\":1632,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1633\",\"data\":{\"Heading\":246,\"ID\":58,\"Latitude\":42.56180,\"Longitude\":-70.87048,\"TripID\":116,\"Speed\":19,\"Update Time\":\"2018-01-29T14:23:33.000Z\",\"VehicleID\":1633,\"WorkID\":104}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1634\",\"data\":{\"Heading\":0,\"ID\":59,\"Latitude\":42.37449,\"Longitude\":-71.07984,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T04:26:13.000Z\",\"VehicleID\":1634,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1635\",\"data\":{\"Heading\":75,\"ID\":60,\"Latitude\":42.37544,\"Longitude\":-71.07501,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2016-01-20T16:55:12.000Z\",\"VehicleID\":1635,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1636\",\"data\":{\"Heading\":331,\"ID\":61,\"Latitude\":42.40607,\"Longitude\":-71.11536,\"TripID\":321,\"Speed\":30,\"Update Time\":\"2018-01-29T14:23:25.000Z\",\"VehicleID\":1636,\"WorkID\":200}}\n\n",
        "event: put\ndata:{\"path\":\"/results/1637\",\"data\":{\"Heading\":123,\"ID\":62,\"Latitude\":42.37442,\"Longitude\":-71.07525,\"TripID\":0,\"Speed\":0,\"Update Time\":\"2018-01-29T14:23:25.000Z\",\"VehicleID\":1637,\"WorkID\":0}}\n\n",
        "event: put\ndata:{\"path\":\"/results/4043440397\",\"data\":{\"Heading\":0,\"ID\":63,\"Latitude\":0,\"Longitude\":0,\"TripID\":0,\"Speed\":0,\"Update Time\":\"1970-01-01T00:00:00.000Z\",\"VehicleID\":4043440397,\"WorkID\":0}}\n\n",
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
        heading: 0,
        latitude: 42.37393,
        longitude: -71.07462,
        trip: "000",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:30 America/New_York", time_format),
        vehicle_id: 1625,
        block: "000"
      },
      %TrainLoc.Vehicles.Vehicle{
        heading: 0,
        latitude: 42.37433,
        longitude: -71.07749,
        trip: "000",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:30 America/New_York", time_format),
        vehicle_id: 1626,
        block: "000"
      },
      %TrainLoc.Vehicles.Vehicle{
        heading: 279,
        latitude: 42.37435,
        longitude: -71.07744,
        trip: "000",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:31 America/New_York", time_format),
        vehicle_id: 1627,
        block: "000"
      },
      %TrainLoc.Vehicles.Vehicle{
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
        heading: 0,
        latitude: 42.37415,
        longitude: -71.07522,
        trip: "000",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:31 America/New_York", time_format),
        vehicle_id: 1630,
        block: "000"
      },
      %TrainLoc.Vehicles.Vehicle{
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
        heading: 281,
        latitude: 42.37389,
        longitude: -71.07494,
        trip: "000",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:21 America/New_York", time_format),
        vehicle_id: 1632,
        block: "000"
      },
      %TrainLoc.Vehicles.Vehicle{
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
        heading: 123,
        latitude: 42.37442,
        longitude: -71.07525,
        trip: "000",
        speed: 0,
        timestamp: Timex.parse!("2018-01-29 14:23:25 America/New_York", time_format),
        vehicle_id: 1637,
        block: "000"
      }
    ]
  end

  @doc """
  This is the expected return value of `TrainLoc.Conflicts.State.all_conflicts/0` after processing the above messages
  """
  def expected_conflict_state do
    Conflicts.new([
      %Conflict{
        assign_id: "200",
        assign_type: :block,
        service_date: ~D[2018-01-29],
        vehicles: [1631, 1636]
      }
    ])
  end
end
