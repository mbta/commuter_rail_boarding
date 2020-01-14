# CommuterRailBoarding / TrainLoc

There are two applications which are a part of this repository, and run together in AWS.

- CommuterRailBoarding: uploads the Commuter Rail boarding status information
  to an Enhanced TripUpdates JSON file.
- TrainLoc: uploads the train locations to an Enhanced VehiclePositions JSON
  file. It also tracks conflicts where multiple vehicles are logged into the
  same trip.

## Installation/Running

```shell
$ mix deps.get
...
$ export V3_API_KEY=[key from https://api-v3.mbta.com]
$ mix test # V3_API_KEY is required to avoid rate limits
$ export GCS_CREDENTIAL_JSON=[JSON data for Firebase token]
$ export CRB_FIREBASE_URL=[path to departureData Firebase feed]
$ export TRAIN_LOC_FIREBASE_URL=[path to AVLData_from_VehicleLocation Firebase feed]
$ mix run --no-halt
```

## System architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for more information on how
CommuterRailBoarding and TrainLoc work internally.
