#!/usr/bin/env bash

set -x
set -e

if [ -z "$2" ]; then
    CMD="/root/build-3rd-parties.sh /output"
else
    CMD="$2"
fi

PKG_NAME=indy-node
IMAGE_NAME="${PKG_NAME}-build-c7.3.1611"
OUTPUT_VOLUME_NAME="${1:-"${PKG_NAME}-rpm-c7.3.1611"}"

docker build -t "${PKG_NAME}-build-c7.3.1611" -f Dockerfile .
docker volume create --name "${OUTPUT_VOLUME_NAME}"

docker run \
    -i \
    --rm \
    -v "${OUTPUT_VOLUME_NAME}:/output" \
    "${IMAGE_NAME}" \
    $CMD
