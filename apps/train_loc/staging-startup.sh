#!/bin/bash
source ~/.staging.keys
mkdir -p ../log
MIX_ENV=prod elixir --sname trainloc-staging -S mix do deps.get --only prod, compile --force, run --no-halt >> ../log/trainloc-staging.log
