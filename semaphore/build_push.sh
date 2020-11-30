#!/bin/bash
set -e -u

# bash script should be called with aws environment ($APP-dev / $APP-dev-green / $APP-prod)
# other required configuration:
# * APP
# * DOCKER_REPO
awsenv=$1

# log into docker hub if needed
if [ -n "$DOCKER_USERNAME" ]; then
    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
fi

# build docker image and tag it with git hash and aws environment
githash=$(git rev-parse --short HEAD)
docker build -t $APP:latest .
docker tag $APP:latest $DOCKER_REPO:$awsenv
docker tag $APP:latest $DOCKER_REPO:git-$githash

# push images to ECS image repo
logincmd=$(aws ecr get-login --no-include-email --region us-east-1)
eval $logincmd
docker push $DOCKER_REPO:$awsenv
docker push $DOCKER_REPO:git-$githash
