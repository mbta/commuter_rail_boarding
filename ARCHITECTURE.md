# TrainLoc Architecture

`Keolis -> TrainLoc -> Splunk Cloud & S3`

Overall, TrainLoc is made up of a few GenServers that fetch vehicle
position/assignment events from [Keolis](http://www.keoliscs.com/about-us/),
reports conflicting assignment data to [Splunk
Cloud](https://www.splunk.com/en_us/products/splunk-cloud.html), and vehicle
positions to [S3](https://aws.amazon.com/s3/).


      ┌────────────────────────────┐
      │TrainLoc.Input.APIFetcher   │
      │                            │
      │                            │
      │                            │
      └────────────────────────────┘            ┌────────────────────────────┐
                     │                          │TrainLoc.Conflicts.State    │
                     │                          │                            │
                   Events                ┌─────▶│                            │
                     │                   │      │                            │
                     ▼                   │      └────────────────────────────┘
      ┌────────────────────────────┐     │      ┌────────────────────────────┐
      │TrainLoc.Manager            │     │      │TrainLoc.Vehicles.State     │
      │                            │  Consults  │                            │
      │                            │◀───and────▶│                            │
      │                            │  Updates   │                            │
      └────────────────────────────┘            └────────────────────────────┘
                     │         │
                     │         │
                Conflicting    │
                Assignment     │
                   Data        └VehiclePositions_enhanced.json┐
                     │                                        │
                     │                                        │
    ─ ─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                     │        Application Boundary            │
                     ▼                                        ▼
      ┌────────────────────────────┐           ┌────────────────────────────┐
      │Splunk Cloud                │           │S3                          │
      │                            │           │                            │
      │                            │           │                            │
      │                            │           │                            │
      └────────────────────────────┘           └────────────────────────────┘


## Data

Throughout the application, data is represented as one of two structs:

* `Vehicle`: position and trip/block assignment
* `Conflict`: conflicting assignment and vehicles involved

## TrainLoc.Input.APIFetcher

Starts and maintains a connection to the Keolis event stream, which reports
vehicle positions and assignment information. The events are sent to
`TrainLoc.Manager` for processing.

## TrainLoc.Manager

Updates application's state, determines conflicting assignments, reports
conflict related data to Splunk Cloud, and vehicle positions to S3.
