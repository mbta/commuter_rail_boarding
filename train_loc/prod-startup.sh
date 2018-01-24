#!/bin/bash
source ~/.prod.keys
mkdir -p ../log
MIX_ENV=prod DELAY=60000 elixir --sname trainloc-prod -S mix do deps.get --only prod, compile --force, run --no-halt >> ../log/trainloc-prod.log
