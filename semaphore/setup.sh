#!/usr/bin/bash
mix local.hex --force
mix local.rebar --force

MIX_ENV=test mix do deps.get, deps.compile
