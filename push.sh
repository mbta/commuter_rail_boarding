#!/bin/sh
# Pushes to the configured DOCKER_REPO
#
# Usage:
# $ sh push.sh      # pushes the local latest build to :latest and :<git SHA>
# $ sh push.sh prod # pushes the local latest build to :prod and :<git SHA>
set -e
SHA=git-$(git rev-parse HEAD)
MODE=latest
if [ "x$1" != x ]; then
    MODE=$1
fi
docker tag commuter_rail_boarding:latest $DOCKER_REPO:$MODE
docker tag commuter_rail_boarding:latest $DOCKER_REPO:$SHA
$(aws/bin/aws ecr get-login --no-include-email)
docker push $DOCKER_REPO:$MODE
docker push $DOCKER_REPO:$SHA
