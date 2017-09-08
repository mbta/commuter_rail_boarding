defmodule TrainLoc.Vehicles.VehiclesTest do
    use ExUnit.Case, async: true
    alias TrainLoc.Vehicles.Vehicles
    alias TrainLoc.Vehicles.Vehicle
    alias TrainLoc.Vehicles.Vehicle.GPS

    test "Stores and deletes train vehicles" do
        vehicles = %{}
        assert Vehicles.get(vehicles, "1712") == nil

        test_vehicle = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:01:51],
            type: "Location",
            operator: "910",
            workpiece: "802",
            pattern: "509",
            gps: %GPS{
                time: "54109",
                lat: "+4224023",
                long: "-07112890",
                speed: "000",
                heading: "188",
                source: "1",
                age: "2"
            }
        }

        {:ok, vehicles} = Vehicles.put(vehicles, "1712", test_vehicle)
        assert Vehicles.get(vehicles, "1712") == test_vehicle

        {:ok, vehicles} = Vehicles.delete(vehicles, "1712")
        assert Vehicles.get(vehicles, "1712") == nil
    end

    test "overwrites older data on update" do
        test_vehicle = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:01:51],
            type: "Location",
            operator: "910",
            workpiece: "802",
            pattern: "509",
            gps: %GPS{
                time: "54109",
                lat: "+4224023",
                long: "-07112890",
                speed: "000",
                heading: "188",
                source: "1",
                age: "2"
            }
        }
        new_vehicle = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:02:51],
            type: "Location",
            operator: "910",
            workpiece: "802",
            pattern: "509",
            gps: %GPS{
                time: "54169",
                lat: "+4224123",
                long: "-07111890",
                speed: "000",
                heading: "188",
                source: "1",
                age: "2"
            }
        }
        #"Update" vehicle with no prior state -> should store new state
        {:ok, vehicles} = Vehicles.update(%{}, {"1712", test_vehicle})
        assert Vehicles.get(vehicles, "1712") == test_vehicle

        #Update vehicle using more recent timestamp -> should overwrite old value
        {:ok, vehicles} = Vehicles.update(vehicles, "1712", new_vehicle)
        assert Vehicles.get(vehicles, "1712") == new_vehicle

        #Try to update vehicle using older timestamp -> shouldn't overwrite
        {:ok, vehicles} = Vehicles.update(vehicles, "1712", test_vehicle)
        assert Vehicles.get(vehicles, "1712") == new_vehicle
    end

    test "Identifies duplicate logins" do
        vehicle_one = %Vehicle{
            vehicle_id: "1712",
            timestamp: ~N[2017-08-04 11:01:51],
            type: "Location",
            operator: "910",
            workpiece: "802",
            pattern: "509",
            gps: %GPS{
                time: "54109",
                lat: "+4224023",
                long: "-07112890",
                speed: "000",
                heading: "188",
                source: "1",
                age: "2"
            }
        }
        vehicle_two = %Vehicle{
            vehicle_id: "1713",
            timestamp: ~N[2017-08-04 11:01:51],
            type: "Location",
            operator: "910",
            workpiece: "803",
            pattern: "508",
            gps: %GPS{
                time: "54109",
                lat: "+4224023",
                long: "-07112890",
                speed: "000",
                heading: "188",
                source: "1",
                age: "2"
            }
        }
        vehicle_three = %Vehicle{
            vehicle_id: "1714",
            timestamp: ~N[2017-08-04 11:01:51],
            type: "Location",
            operator: "910",
            workpiece: "803",
            pattern: "508",
            gps: %GPS{
                time: "54109",
                lat: "+4224023",
                long: "-07112890",
                speed: "000",
                heading: "188",
                source: "1",
                age: "2"
            }
        }
        vehicle_four = %Vehicle{
            vehicle_id: "1715",
            timestamp: ~N[2017-08-04 11:01:51],
            type: "Location",
            operator: "910",
            workpiece: "802",
            pattern: "510",
            gps: %GPS{
                time: "54109",
                lat: "+4224023",
                long: "-07112890",
                speed: "000",
                heading: "188",
                source: "1",
                age: "2"
            }
        }
        #Same Pattern: vehicle_two & vehicle_three
        #Same Workpiece: vehicle_one & vehicle_four; vehicle_two & vehicle_three
        vehicles = %{} |> Map.put("1712", vehicle_one) |> Map.put("1713", vehicle_two) |> Map.put("1714", vehicle_three) |> Map.put("1715", vehicle_four)
        assert Vehicles.find_duplicate_logons(vehicles) == {
            [{"508", [vehicle_two, vehicle_three]}],
            [{"802", [vehicle_one, vehicle_four]},
             {"803", [vehicle_two, vehicle_three]}]
        }
    end
end
