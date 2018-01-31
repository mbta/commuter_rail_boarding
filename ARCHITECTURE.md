# TrainLoc Architecture

`Keolis -> TrainLoc -> Splunk Cloud`

Overall, TrainLoc is made up of a few GenServers that fetch vehicle assignment
events from [Keolis](http://www.keoliscs.com/about-us/), detect conflicting assignment related data, and report it
to [Splunk Cloud](https://www.splunk.com/en_us/products/splunk-cloud.html).


      ┌────────────────────────────┐
      │TrainLoc.Input.APIFetcher   │
      │                            │
      │                            │
      │                            │                ┌────────────────────────────┐
      └────────────────────────────┘                │TrainLoc.Conflicts.State    │
                     │                              │                            │
                     │                     ┌───────▶│                            │
                   Events                  │        │                            │
                     │                     │        └────────────────────────────┘
                     ▼                     │
      ┌────────────────────────────┐       │        ┌────────────────────────────┐
      │TrainLoc.Manager            │       │        │TrainLoc.Assignments.State  │
      │                            │    Consults    │                            │
      │                            │◀─────and──────▶│                            │
      │                            │    Updates     │                            │
      └────────────────────────────┘       │        └────────────────────────────┘
                     │                     │
                Conflicting                │        ┌────────────────────────────┐
                Assignments                │        │TrainLoc.Vehicles.State     │
                     &                     │        │                            │
               Related Data                └───────▶│                            │
                     │                              │                            │
                     │                              └────────────────────────────┘
    ─ ─ ─ ─ ─ ─ ─ ─ ─│─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
                     │          Application Boundary
                     ▼
      ┌────────────────────────────┐
      │Splunk Cloud                │
      │                            │
      │                            │
      │                            │
      └────────────────────────────┘


## Data

Throughout the application, data is represented as one of three structs:

* `Vehicle`: location, trajectory, and trip/block assignment
* `Assignment`: historical vehicle assignment
* `Conflict`: conflicting assignment and vehicles involved

## TrainLoc.Input.APIFetcher

Starts and maintains a connection to the Keolis event stream, which reports
vehicle assignment information. The events are sent to `TrainLoc.Manager` for
processing.

## TrainLoc.Manager

Consults the application's state, determines conflicting assignments, updates
the application's state, and reports conflict related data to Splunk Cloud.
