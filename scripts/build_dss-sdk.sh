#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# The Clear BSD License
#
# Copyright (c) 2022 Samsung Electronics Co., Ltd.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted (subject to the limitations in the disclaimer
# below) provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of Samsung Electronics Co., Ltd. nor the names of its
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
# NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
# THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
# NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Build nkv-sdk components: target, host, ufm, agent

set -e

# Load utility functions
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
. "$SCRIPT_DIR/utils.sh"

# Set build variables
HOST_BUILD_MODE='kdd-samsung-remote'

# Check for submodules in update init recursive if missing
checksubmodules

# Build dss-sdk
"$DSS_SDK_DIR/scripts/build_all.sh" "$HOST_BUILD_MODE"

# Set artifacts build directory paths
target_build_dir="${DSS_DIR}/dss-sdk/df_out"
host_build_dir="${DSS_DIR}/dss-sdk/host_out"
nkv_agent_build_dir="${DSS_DIR}/dss-sdk/ufm/agents/nkv_agent"
ufm_build_dir="${DSS_DIR}/dss-sdk/ufm/fabricmanager"
ufm_broker_build_dir="${DSS_DIR}/dss-sdk/ufm/ufm_msg_broker"

echo "Removing existing artifacts from artifacts directory..."
rm -f "${ARTIFACTS_DIR}"/nkv-target-*.tgz
rm -f "${ARTIFACTS_DIR}"/nkv-sdk-bin-*.tgz
rm -f "${ARTIFACTS_DIR}"/nkvagent-*.rpm
rm -f "${ARTIFACTS_DIR}"/ufm-*.rpm
rm -f "${ARTIFACTS_DIR}"/ufmbroker-*.rpm

echo "Copying artifacts to artifacts directory..."
cp "${target_build_dir}"/nkv-target-*.tgz "${ARTIFACTS_DIR}"
cp "${host_build_dir}"/nkv-sdk-bin-*.tgz "${ARTIFACTS_DIR}"
cp "${nkv_agent_build_dir}"/nkvagent-*.rpm "${ARTIFACTS_DIR}"
cp "${ufm_build_dir}"/ufm-*.rpm "${ARTIFACTS_DIR}"
cp "${ufm_broker_build_dir}"/ufmbroker-*.rpm "${ARTIFACTS_DIR}"