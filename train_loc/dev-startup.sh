#!/bin/bash
source ~/.dev.keys
mkdir -p ../log
MIX_ENV=dev elixir --sname trainloc-dev -S mix do deps.get --only prod, compile --force, run --no-halt >> ../log/trainloc-dev.log
