#! /usr/bin/env bash
set -e

# Build dss-gcc in Docker
DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
"$DOCKER_DIR"/build_docker.sh -c kernel -d kernel -t kernelbuild -a 'kernel-5.1.0-*.rpm kernel-devel-5.1.0-*.rpm kernel-headers-5.1.0-*.rpm'
