#! /usr/bin/env bash
# shellcheck disable=SC1091
set -e

# Load utility functions
DOCKER_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$DOCKER_DIR/../utils.sh"

# DSS Dependencies
"$DOCKER_DIR"/build_aws-sdk.sh
"$DOCKER_DIR"/build_kernel.sh
"$DOCKER_DIR"/build_mlnx-tools.sh

# Build DSS
"$DOCKER_DIR"/build_dss-sdk.sh
"$DOCKER_DIR"/build_minio.sh
"$DOCKER_DIR"/build_dss-client.sh
"$DOCKER_DIR"/build_datamover.sh
