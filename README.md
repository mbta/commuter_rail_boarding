# Trainloc

This application monitors MBTA Commuter Rail data regarding locations and assignments of CR trains.
It currently logs any instances of multiple trainsets logged into the same trip or block (logs are
sent to and analyzed by Logentries, which sends email notifications for each identified conflict).

Future functionality will include tracking the relationship between trips and blocks, so the blocks
can be added to the MBTA's GTFS feed, and potentially replacing existing processes that transfer the
real-time location and assignment data to the CR prediction provider.

## Usage

The app is started using a shell script `*-startup.sh` (with the asterisk replaced by the environment name,
e.g. `dev`), which sets necessary environment variables and starts the process.
* Sensitive parameters are declared separately in a `~/.*.keys` file (with the same environment name as the startup file),
in the format `export PARAM_NAME=value`.  
Required parameters are `FTP_USERNAME` and `FTP_PASSWORD` (and `LOGENTRIES_TOKEN` if logs are to be tracked)

Once started, the application's current state can be probed from anywhere on the network by using `iex`:
1. Ensure you have a file `~/.erlang.cookie` containing the string "BGJRNXPUOSSJNMBXKYWO".
(Otherwise, TrainLoc will deny the connection.)
2. Open Interactive Elixir in a terminal window using `iex --sname test`.
3. Retrieve data from GenServer interfaces using `GenServer.call/2`, with a `{module_name, node}` tuple as the first parameter. `node` will be an atom of the form `:"trainloc-<environment>@<computer-name>"`
    * *Note:* For convenience, it is recommended to assign the tuple to a variable in `iex` if you intend to make multiple calls.

  Example:
```elixir
iex> vehicle_state = {TrainLoc.Vehicles.State, :"trainloc-dev@mycomputer"}
{TrainLoc.Vehicles.State, :"trainloc-dev@mycomputer"}
iex> GenServer.call(vehicle_state, :all_ids)
["1707", "1634", "1531", "1630", "1649", "1507", "1506", "1709", "1821", "1724",
...]
```
