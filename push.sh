#!/bin/sh

docker tag commuter_rail_boarding:latest $DOCKER_REPO:latest

docker push $DOCKER_REPO:latest
