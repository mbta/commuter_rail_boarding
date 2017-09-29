defmodule TrainLoc.Vehicles.VehiclesTest do
    use ExUnit.Case, async: true
    alias Timex.Duration
    alias TrainLoc.Vehicles.Vehicles
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Vehicles.Vehicle.GPS
    alias TrainLoc.Conflicts.Conflict
    doctest Vehicles

    test "Stores and deletes train vehicles" do
        vehicles = %{}
        assert Vehicles.get(vehicles, "1712") == nil

        test_vehicle = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:01:51],
            operator: "910",
            block: "802",
            trip: "509",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 0,
                heading: 188,
                source: 1,
                age: 2
            }
        }

        {:ok, vehicles} = Vehicles.put(vehicles, test_vehicle)
        assert Vehicles.get(vehicles, "1712") == test_vehicle

        {:ok, vehicles} = Vehicles.delete(vehicles, "1712")
        assert Vehicles.get(vehicles, "1712") == nil
    end

    test "overwrites older data on update" do
        test_vehicle = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:01:51],
            operator: "910",
            block: "802",
            trip: "509",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 0,
                heading: 188,
                source: 1,
                age: 2
            }
        }
        new_vehicle = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:02:51],
            operator: "910",
            block: "802",
            trip: "509",
            gps: %GPS{
                time: 54169,
                lat: 42.24123,
                long: -71.11890,
                speed: 0,
                heading: 188,
                source: 1,
                age: 2
            }
        }
        #"Update" vehicle with no prior state -> should store new state
        {:ok, vehicles} = Vehicles.update(%{}, test_vehicle)
        assert Vehicles.get(vehicles, "1712") == test_vehicle

        #Update vehicle using more recent timestamp -> should overwrite old value
        {:ok, vehicles} = Vehicles.update(vehicles, new_vehicle)
        assert Vehicles.get(vehicles, "1712") == new_vehicle

        #Try to update vehicle using older timestamp -> shouldn't overwrite
        {:ok, vehicles} = Vehicles.update(vehicles, test_vehicle)
        assert Vehicles.get(vehicles, "1712") == new_vehicle
    end

    test "Identifies duplicate logins" do
        vehicle_one = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:01:51],
            operator: "910",
            block: "802",
            trip: "509",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 0,
                heading: 188,
                source: 1,
                age: 2
            }
        }
        vehicle_two = %Vehicle{
            vehicle_id: "1713",
            timestamp: ~N[2017-08-04 11:01:51],
            operator: "910",
            block: "803",
            trip: "508",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 0,
                heading: 188,
                source: 1,
                age: 2
            }
        }
        vehicle_three = %Vehicle{
            vehicle_id: "1714",
            timestamp: ~N[2017-08-04 11:01:51],
            operator: "910",
            block: "803",
            trip: "508",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 000,
                heading: 188,
                source: 1,
                age: 2
            }
        }
        vehicle_four = %Vehicle{
            vehicle_id: "1715",
            timestamp: ~N[2017-08-04 11:01:51],
            operator: "910",
            block: "802",
            trip: "510",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -071.12890,
                speed: 000,
                heading: 188,
                source: 1,
                age: 2
            }
        }
        #Same Pattern: vehicle_two & vehicle_three
        #Same Workpiece: vehicle_one & vehicle_four; vehicle_two & vehicle_three
        vehicles = %{} |> Map.put("1712", vehicle_one) |> Map.put("1713", vehicle_two) |> Map.put("1714", vehicle_three) |> Map.put("1715", vehicle_four)
        assert Vehicles.find_duplicate_logons(vehicles) == [
            %Conflict{
                assign_type: :trip,
                assign_id: "508",
                vehicles: ["1713", "1714"],
                service_date: ~D[2017-08-04]
            },
            %Conflict{
                assign_type: :block,
                assign_id: "802",
                vehicles: ["1712", "1715"],
                service_date: ~D[2017-08-04]
            },
            %Conflict{
                assign_type: :block,
                assign_id: "803",
                vehicles: ["1713", "1714"],
                service_date: ~D[2017-08-04]
            }
        ]
    end

    test "purges vehicles older than a given age" do
        vehicle_one = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:01:51],
            operator: "910",
            block: "802",
            trip: "509",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 0,
                heading: 188,
                source: 1,
                age: 2
            }
        }
        vehicle_two = %Vehicle{
            vehicle_id: "1713",
            timestamp: ~N[2017-08-03 11:01:50],
            operator: "910",
            block: "803",
            trip: "507",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 0,
                heading: 188,
                source: 1,
                age: 2
            }
        }
        vehicle_three = %Vehicle{
            vehicle_id: "1714",
            timestamp: ~N[2017-08-04 11:01:51],
            operator: "910",
            block: "804",
            trip: "508",
            gps: %GPS{
                time: 54109,
                lat: 42.24023,
                long: -71.12890,
                speed: 000,
                heading: 188,
                source: 1,
                age: 2
            }
        }

        vehicles = %{"1712" => vehicle_one, "1713" => vehicle_two, "1714" => vehicle_three}

        assert Vehicles.purge_old_vehicles(vehicles, Duration.from_days(1)) == {
            :ok,
            %{"1712" => vehicle_one, "1714" => vehicle_three},
            [vehicle_two]
        }
    end
end
