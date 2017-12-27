#!/bin/bash
set -e -x
APP=commuter_rail_boarding
docker build -t $APP:latest .
