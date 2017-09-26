# Trainloc

This application monitors MBTA Commuter Rail data regarding locations and assignments of CR trains.
It currently logs any instances of multiple trainsets logged into the same trip or block (logs are
sent to and analyzed by Logentries, which sends email notifications for each identified conflict).

Future functionality will include tracking the relationship between trips and blocks, so the blocks
can be added to the MBTA's GTFS feed, and potentially replacing existing processes that transfer the
real-time location and assignment data to the CR prediction provider.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `trainloc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:trainloc, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/trainloc](https://hexdocs.pm/trainloc).
