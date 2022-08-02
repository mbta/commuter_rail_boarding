# System Architectures

## CommuterRailBoarding

### Process Tree

The Commuter Rail Boarding application is implemented as a [GenStage][gen_stage]
pipeline with four steps:

* ServerSentEventStage
* BoardingStatus.ProducerConsumer
* TripUpdates.ProducerConsumer
* Uploader.Consumer

#### ServerSentEventStage

Provided by
[`server_sent_event_stage`](https://hex.pm/packages/server_sent_event_stage),
this turns the Firebase feed into a stage of `%ServerSentEventStage.Event{}` structs.

#### BoardingStatus.ProducerConsumer

BS.PC turns a `%ServerSentEventStage.Event{}` into a list of `%BoardingStatus{}` structs.
It's a simplified mapping of the data, but one that makes it straightforward
for downstream consumers of a `%BoardingStatus{}` to work with.

The parsing itself is done by the BoardingStatus module, and that also has
more documentation about the struct and data formats.

#### TripUpdates.ProducerConsumer

TU.PC takes the list of `%BoardingStatus{}` structs and produces a binary of
the TripUpdates enhanced JSON file. The TripUpdates module generates a map,
and TU.PC converts it to JSON before passing it to the next stage.  For more
information, see the documentation in the TripUpdates module.

#### Uploader.Consumer

The final step in the pipeline, U.C is responsible for putting the JSON data
somewhere.  In production, this uses Uploader.S3 to put the JSON into a
bucket.  In development, Uploader.Console logs the JSON to the console.

#### Other workers

* TripCache: stores the mapping from Trip IDs to a route ID and direction ID

## TrainLoc

`Keolis -> TrainLoc -> Splunk Cloud & S3`

Overall, TrainLoc is made up of a few GenServers that fetch vehicle
position/assignment events from [Keolis](http://www.keoliscs.com/about-us/),
reports conflicting assignment data to [Splunk
Cloud](https://www.splunk.com/en_us/products/splunk-cloud.html), and vehicle
positions to [S3](https://aws.amazon.com/s3/).


      ┌────────────────────────────┐
      │ServerSentEventStage        │
      │                            │
      │                            │
      │                            │
      └────────────────────────────┘            
                     │                          
                     │                          
                   Events                
                     │                   
                     ▼                   
      ┌────────────────────────────┐     
      │TrainLoc.Manager            │    
      │                            │  
      │                            │
      │                            │ 
      └────────────────────────────┘ 
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


### Data

Throughout the application, data is represented as one of two structs:

* `Vehicle`: position and trip/block assignment

### ServerSentEventStage

Provided by
[`server_sent_event_stage`](https://hex.pm/packages/server_sent_event_stage),
this turns the Firebase feed into a stage of `%ServerSentEventStage.Event{}` structs.

### TrainLoc.Manager

Updates application's state, determines conflicting assignments, reports
conflict related data to Splunk Cloud, and vehicle positions to S3.

## Build/Deployment

Both applications are built together in an Alpine Linux Docker container
(Dockerfile). The container makes a release build using
[Distillery][distillery], and then a second stage builds the deployment
container without any of the build dependencies.

We push the release container (tagged with `git-<SHA>` and `latest`)
to [Amazon EC2 Container Registry][ecr] and run it
on [Amazon EC2 Container Service][ecs]. This is run by the
`commuter-rail-boarding-dev` ECS service.

Once the release has been validated, we tag the container with `prod`. This
is run by the `commuter-rail-boarding-prod` ECS service.

Both services run in the `commuter-rail-boarding` cluster.

[gen_stage]: https://github.com/elixir-lang/gen_stage
[server_sent_event]: https://html.spec.whatwg.org/multipage/server-sent-events.html#parsing-an-event-stream
[httpoison]: https://github.com/edgurgel/httpoison
[distillery]: https://github.com/bitwalker/distillery
[ecr]: https://aws.amazon.com/ecr/
[ecs]: https://aws.amazon.com/ecs/
