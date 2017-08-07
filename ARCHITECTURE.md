# System Architecture

## Process Tree

The Commuter Rail Boarding application is implemented as a [GenStage][gen_stage]
pipeline with four steps:

* ServerSentEvent.Producer
* BoardingStatus.ProducerConsumer
* TripUpdates.ProducerConsumer
* Uploader.Consumer

### ServerSentEvent.Producer

SSE.P is responsible for managing the connecting to the remote server,
parsing the [Server Sent Event][server_sent_event] protocol, and passing the
parsed event to its consumers.  Currently, it uses [HTTPoison][httpoison]'s
async protocol to receive chunks of data. Once a full event has been
received, it uses the ServerSentEvent module to parse the event into a
structure (`%ServerSentEvent{}`) that downstream consumers work with.

### BoardingStatus.ProducerConsumer

BS.PC turns a `%ServerSentEvent{}` into a list of `%BoardingStatus{}` structs.
It's a simplified mapping of the data, but one that makes it straightforward
for downstream consumers of a `%BoardingStatus{}` to work with.

The parsing itself is done by the BoardingStatus module, and that also has
more documentation about the struct and data formats.

### TripUpdates.ProducerConsumer

TU.PC takes the list of `%BoardingStatus{}` structs and produces a binary of
the TripUpdates enhanced JSON file. The TripUpdates module generates a map,
and TU.PC converts it to JSON before passing it to the next stage.  For more
information, see the documentation in the TripUpdates module.

### Uploader.Consumer

The final step in the pipeline, U.C is responsible for putting the JSON data
somewhere.  In production, this uses Uploader.S3 to put the JSON into a
bucket.  In development, Uploader.Console logs the JSON to the console.

### Other workers

* TripCache: stores the mapping from Trip IDs to a route ID and direction ID

## Build/Deployment

The application is built in an Alpine Linux Docker container
(Dockerfile). The container makes a release build
using [Distillery][distillery], and then we pull the compiled files out of
the container.

Next, we make the release container (rel/Dockerfile) which runs the actual
Erlang VM.

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
