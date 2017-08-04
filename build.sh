#!/bin/bash
set -e -x
PREFIX=_build/prod/
APP=commuter_rail_boarding
BUILD_TAG=$APP:_build
VERSION=$(grep -o 'version: .*"' mix.exs | grep -E -o '([0-9]+\.)+[0-9]+')

docker build -t $BUILD_TAG .
CONTAINER=$(docker run -d ${BUILD_TAG} sleep 2000)

docker cp $CONTAINER:/root/${PREFIX}rel/$APP/releases/$VERSION/$APP.tar.gz rel/$APP.tar.gz

docker kill $CONTAINER
docker rm $CONTAINER
pushd rel
for path in bin erts* lib releases; do test -e $path && rm -r $path; done
tar -zxf $APP.tar.gz
rm $APP.tar.gz
docker build -t $APP:latest .
popd > /dev/null
