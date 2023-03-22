#! /usr/bin/env bash
set -e

# Build dss-gcc in Docker
DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
"$DOCKER_DIR"/build_docker.sh -c gcc -t gccbuild -a 'dss-gcc510-*.rpm'
