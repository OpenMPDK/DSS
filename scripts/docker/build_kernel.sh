#! /usr/bin/env bash
set -e

# Build dss-gcc in Docker
DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
"$DOCKER_DIR"/build_docker.sh -c kernel -d kernel -t kernelbuild -a 'kernel-*.rpm'
