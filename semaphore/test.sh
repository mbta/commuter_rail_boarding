#!/usr/bin/bash
set -e
set -x

mix compile --force --warnings-as-errors
mix test
