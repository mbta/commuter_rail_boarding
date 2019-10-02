defmodule Busloc.VehicleTest do
  use ExUnit.Case, async: true
  alias Busloc.Vehicle
  import Busloc.Vehicle
  alias Busloc.Utilities.Time, as: BuslocTime

  doctest Busloc.Vehicle

  describe "from_transitmaster_map/2" do
    test "parses a map into a Vehicle struct" do
      map = %{
        block: "A60-36",
        run: "123-2468",
        overload_id: 1,
        overload_offset: -2,
        fig_merit: 1,
        route: "09",
        trip: "36680082",
        heading: 135,
        latitude: 42.3218438,
        longitude: -71.1777327,
        timestamp: "150646",
        vehicle_id: "0401",
        service_date: "20180430"
      }

      datetime = Timex.to_datetime(~N[2018-03-26T15:11:05], "America/New_York")

      expected =
        {:ok,
         %Vehicle{
           vehicle_id: "0401",
           route: "9",
           trip: "36680082",
           block: "A60-36",
           run: "123-2468",
           overload_id: 1,
           overload_offset: -2,
           fig_merit: 1,
           latitude: 42.3218438,
           longitude: -71.1777327,
           heading: 135,
           source: :transitmaster,
           timestamp: BuslocTime.parse_transitmaster_timestamp("150646", datetime),
           assignment_timestamp: BuslocTime.parse_transitmaster_timestamp("150646", datetime),
           start_date: ~D[2018-04-30]
         }}

      actual = from_transitmaster_map(map, datetime)
      assert expected == actual
    end

    test "empty run ID, route ID and trip ID, and 0 overload_id, lat, long are converted to nil" do
      map = %{
        block: "A60-36",
        run: "",
        overload_id: 0,
        overload_offset: 0,
        fig_merit: 100,
        route: "",
        trip: "0",
        heading: 135,
        latitude: 0,
        longitude: 0,
        timestamp: "150646",
        vehicle_id: "0401",
        service_date: "20180430"
      }

      datetime = Timex.to_datetime(~N[2018-03-26T15:11:05], "America/New_York")

      assert {:ok,
              %Vehicle{
                run: nil,
                overload_id: nil,
                overload_offset: nil,
                fig_merit: 100,
                trip: nil,
                route: nil,
                latitude: nil,
                longitude: nil
              }} = from_transitmaster_map(map, datetime)
    end

    test "returns an error if we're unable to convert the map" do
      assert {:error, _} = from_transitmaster_map(%{}, DateTime.utc_now())
    end
  end

  describe "log_line/2" do
    test "logs all the data from the vehicle" do
      now = DateTime.from_naive!(~N[2018-03-28T20:15:12], "Etc/UTC")

      vehicle = %Vehicle{
        vehicle_id: "veh_id",
        block: "50",
        run: "123-4321",
        overload_id: 2,
        overload_offset: 5,
        fig_merit: 1,
        latitude: 1.234,
        longitude: -5.678,
        heading: 29,
        source: :transitmaster,
        timestamp: now
      }

      actual = IO.iodata_to_binary(log_line(vehicle, now))
      assert actual =~ ~s(v_id="veh_id")
      assert actual =~ "o_id= "
      assert actual =~ "o_name= "
      assert actual =~ ~s(block="50")
      assert actual =~ ~s(run="123-4321")
      assert actual =~ "overload_id=2"
      assert actual =~ "overload_offset=5"
      assert actual =~ "fig_merit=1"
      refute actual =~ "latitude=1.234"
      refute actual =~ "longitude=-5.678"
      refute actual =~ "heading=29"
      assert actual =~ "v_source=transitmaster"
      assert actual =~ "timestamp=2018-03-28T16:15:12-04:00"
    end

    test "logs if the time is invalid" do
      now = DateTime.from_unix!(2000)

      vehicle = %Vehicle{
        timestamp: DateTime.from_unix!(0)
      }

      actual = IO.iodata_to_binary(log_line(vehicle, now))
      assert actual =~ "invalid_time=stale"
    end
  end

  describe "from_samsara_json/1" do
    test "parses Poison map to Vehicle struct" do
      json_map = %{
        "heading" => 0,
        "id" => 212_014_918_101_455,
        "latitude" => 42.340632833,
        "location" => "Boston, MA",
        "longitude" => -71.058374,
        "name" => "1718",
        "onTrip" => false,
        "speed" => 25,
        "time" => 1_525_100_949_275,
        "vin" => ""
      }

      expected = %Vehicle{
        block: nil,
        heading: 0,
        latitude: 42.340632833,
        longitude: -71.058374,
        speed: 11.1757,
        source: :samsara,
        timestamp: DateTime.from_naive!(~N[2018-04-30 15:09:09.275], "Etc/UTC"),
        vehicle_id: "1718"
      }

      actual = from_samsara_json(json_map)
      assert actual == expected
    end
  end

  describe "from_eyeride_json/1" do
    setup do
      json_map = %{
        "id" => "cbd2f411-7107-45f3-9a99-4d31ea6e8bed",
        "bus" => "43915",
        "created_at" => "2018-05-15T10:28:17Z",
        "ins" => 0,
        "outs" => 0,
        "gps" => %{
          "type" => "Point",
          "coordinates" => [
            42.41673,
            -71.1075
          ]
        },
        "route_name" =>
          "MBTA Route 710 North Medford-Medford Square, Meadow Glen Mall or Wellington Station",
        "speed" => "0.000",
        "route_header" => "Doonan St",
        "direction" => "W"
      }

      {:ok, %{json_map: json_map}}
    end

    test "parses Poison map to Vehicle struct", %{json_map: json_map} do
      timestamp = DateTime.from_naive!(~N[2018-05-15T10:28:17], "Etc/UTC")

      assert %Vehicle{
               latitude: 42.41673,
               longitude: -71.1075,
               source: :eyeride,
               timestamp: ^timestamp,
               vehicle_id: "43915",
               route: "710"
             } = from_eyeride_json(json_map)
    end
  end

  describe "from_saucon_json/1" do
    test "parses Poison map to Vehicle struct" do
      json_map = %{
        "cid" => 294_359_758,
        "name" => "Wollaston Shuttle",
        "routeId" => 88_001_007,
        "vehiclesOnRoute" => [
          %{
            "assetId" => 1_030_243_129,
            "course" => 335.5,
            "lat" => 42.2517056,
            "lon" => -71.0057856,
            "name" => "165",
            "predictedStops" => [
              %{
                "actualArrivalTime" => nil,
                "actualDepartureTime" => nil,
                "name" => "North Quincy MBTA Station",
                "predictedArrivalTime" => nil,
                "predictedDepartureTime" => nil,
                "scheduledArrivalTime" => nil,
                "scheduledDepartureTime" => 1_526_029_200_000,
                "sequence" => 0,
                "stopId" => 3_833_839,
                "timezone" => "US/Eastern"
              },
              %{
                "actualArrivalTime" => nil,
                "actualDepartureTime" => nil,
                "name" => "Wollaston - Hancock St @ Woodbine St",
                "predictedArrivalTime" => nil,
                "predictedDepartureTime" => nil,
                "scheduledArrivalTime" => nil,
                "scheduledDepartureTime" => 1_526_029_800_000,
                "sequence" => 1,
                "stopId" => 3_833_870,
                "timezone" => "US/Eastern"
              }
            ],
            "speed" => 22.6703,
            "timestamp" => 1_526_074_417_638
          },
          %{
            "assetId" => 1_030_243_129,
            "course" => 335.5,
            "lat" => 42.2517056,
            "lon" => -71.0057856,
            "name" => "165",
            "predictedStops" => [
              %{
                "actualArrivalTime" => nil,
                "actualDepartureTime" => nil,
                "name" => "North Quincy MBTA Station",
                "predictedArrivalTime" => nil,
                "predictedDepartureTime" => nil,
                "scheduledArrivalTime" => nil,
                "scheduledDepartureTime" => 1_526_033_400_000,
                "sequence" => 0,
                "stopId" => 3_833_840,
                "timezone" => "US/Eastern"
              },
              %{
                "actualArrivalTime" => nil,
                "actualDepartureTime" => nil,
                "name" => "Wollaston - Hancock St @ Woodbine St",
                "predictedArrivalTime" => nil,
                "predictedDepartureTime" => nil,
                "scheduledArrivalTime" => nil,
                "scheduledDepartureTime" => 1_526_034_000_000,
                "sequence" => 1,
                "stopId" => 3_833_871,
                "timezone" => "US/Eastern"
              }
            ],
            "speed" => 22.6703,
            "timestamp" => 1_526_074_417_638
          },
          %{
            "assetId" => 1_030_107_840,
            "course" => 162.2,
            "lat" => 42.2768192,
            "lon" => -71.0308544,
            "name" => "130",
            "predictedStops" => [
              %{
                "actualArrivalTime" => nil,
                "actualDepartureTime" => nil,
                "name" => "North Quincy MBTA Station",
                "predictedArrivalTime" => nil,
                "predictedDepartureTime" => nil,
                "scheduledArrivalTime" => nil,
                "scheduledDepartureTime" => 1_526_029_200_000,
                "sequence" => 0,
                "stopId" => 3_833_839,
                "timezone" => "US/Eastern"
              },
              %{
                "actualArrivalTime" => nil,
                "actualDepartureTime" => nil,
                "name" => "Wollaston - Hancock St @ Woodbine St",
                "predictedArrivalTime" => nil,
                "predictedDepartureTime" => nil,
                "scheduledArrivalTime" => nil,
                "scheduledDepartureTime" => 1_526_029_800_000,
                "sequence" => 1,
                "stopId" => 3_833_870,
                "timezone" => "US/Eastern"
              }
            ],
            "speed" => 0.0,
            "timestamp" => 1_526_073_969_329
          }
        ]
      }

      expected = [
        %Vehicle{
          block: nil,
          heading: 336,
          latitude: 42.2517056,
          longitude: -71.0057856,
          speed: 10.1342,
          route: "Shuttle005",
          source: :saucon,
          timestamp: DateTime.from_naive!(~N[2018-05-11 21:33:37.638], "Etc/UTC"),
          assignment_timestamp: DateTime.from_naive!(~N[2018-05-11 21:33:37.638], "Etc/UTC"),
          vehicle_id: "saucon165"
        },
        %Vehicle{
          block: nil,
          heading: 336,
          latitude: 42.2517056,
          longitude: -71.0057856,
          speed: 10.1342,
          route: "Shuttle005",
          source: :saucon,
          timestamp: DateTime.from_naive!(~N[2018-05-11 21:33:37.638], "Etc/UTC"),
          assignment_timestamp: DateTime.from_naive!(~N[2018-05-11 21:33:37.638], "Etc/UTC"),
          vehicle_id: "saucon165"
        },
        %Vehicle{
          block: nil,
          heading: 162,
          latitude: 42.2768192,
          longitude: -71.0308544,
          speed: 0,
          route: "Shuttle005",
          source: :saucon,
          timestamp: DateTime.from_naive!(~N[2018-05-11 21:26:09.329], "Etc/UTC"),
          assignment_timestamp: DateTime.from_naive!(~N[2018-05-11 21:26:09.329], "Etc/UTC"),
          vehicle_id: "saucon130"
        }
      ]

      actual = from_saucon_json(json_map)
      assert actual == expected
    end

    test "skips vehicles with null course" do
      json_map = %{
        "cid" => 294_359_758,
        "name" => "Wollaston Shuttle",
        "routeId" => 88_001_007,
        "vehiclesOnRoute" => [
          %{
            "assetId" => 1_030_243_129,
            "course" => nil,
            "lat" => 42.2517056,
            "lon" => -71.0057856,
            "name" => "165",
            "predictedStops" => [
              %{
                "actualArrivalTime" => nil,
                "actualDepartureTime" => nil,
                "name" => "North Quincy MBTA Station",
                "predictedArrivalTime" => nil,
                "predictedDepartureTime" => nil,
                "scheduledArrivalTime" => nil,
                "scheduledDepartureTime" => 1_526_029_200_000,
                "sequence" => 0,
                "stopId" => 3_833_839,
                "timezone" => "US/Eastern"
              }
            ],
            "speed" => 22.6703,
            "timestamp" => nil
          }
        ]
      }

      expected = []

      actual = from_saucon_json(json_map)
      assert actual == expected
    end
  end
end
