#! /usr/bin/env bash
set -e

# Build aws-sdk-cpp in Docker
DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
"$DOCKER_DIR"/build_docker.sh -c aws-sdk -t awsbuild -a 'aws-sdk-cpp*.rpm'
