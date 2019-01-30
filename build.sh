#!/bin/bash
set -e -x
APP=commuter_rail_boarding
docker build --pull -t $APP:latest .
