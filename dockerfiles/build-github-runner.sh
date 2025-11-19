#!/bin/bash -xe

VERSION=$(date +"%Y-%m-%d")

docker build \
    -t petrows/podman:5.7.0-$VERSION \
    --build-arg version=5.7.0 -f podman.dockerfile .

docker push petrows/podman:5.7.0-$VERSION
