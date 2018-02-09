# Trainloc

[![Build Status](https://semaphoreci.com/api/v1/projects/5cf9d2cb-6d4a-4281-a3cd-24607ac5ed02/1769861/badge.svg)](https://semaphoreci.com/mbta/train_loc)
[![codecov](https://codecov.io/gh/mbta/train_loc/branch/master/graph/badge.svg?token=aYAhtOpcCw)](https://codecov.io/gh/mbta/train_loc)

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for the overall architecture of the system.

## Purpose

This application monitors MBTA Commuter Rail data regarding locations and assignments of CR trains.
It detects any instances of multiple trainsets logged into the same trip or block.
It reports these conflicts and other related data to Splunk Cloud.
It also keeps a `VehiclePositions_enhanced.json` file up to date on S3 for the CR prediction provider to consume.

Future functionality will include tracking the relationship between trips and blocks, so the blocks
can be added to the MBTA's GTFS feed.

## Development Setup

```
# get Elixir dependencies
mix deps.get

# set environment variables
source ~/.dev.keys

# make sure everything passes!
mix test
```

## Usage

The app is started using a shell script `*-startup.sh` (with the asterisk replaced by the environment name,
e.g. `dev`), which sets necessary environment variables and starts the process.
* Sensitive parameters are declared separately in a `~/.*.keys` file (with the same environment name as the startup file). It should look like [.dev.keys.example](.dev.keys.example).

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

## Domain Concepts

* `trainset`: A vehicle struct within this application represents a trainset. A
  trainset is physically a series of connected train cars with a control coach
  at one end (the `id` of which defines the trainset). The `id`s of the other
  cars in the trainset are not reported by Keolis, and so aren't stored in this
  application.

* `trip`: A trip identifies a scheduled commuter rail trip - for example the
  inbound train that is scheduled to leave Worcester at 6:22am is trip 506.

* `block`: A block is a series of trips made by a single trainset in a day,
  usually identified by the trip number of the first trip in that block.

* `train`: "train" is a term that should probably be avoided, since it could
  potentially mean two different things based on interpretation. For example, a
  layperson would probably refer to a trainset as a train, but in all official
  communications, (alerts, etc.) "train" is synonymous with "trip" (i.e. an alert
  about the trip above would call it "train 506")
