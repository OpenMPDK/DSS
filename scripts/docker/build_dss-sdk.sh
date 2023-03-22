#! /usr/bin/env bash
set -e

# Build dss-sdk in Docker
DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
"$DOCKER_DIR"/build_docker.sh -c dss-sdk -t dssbuild -a 'n/a' -u
