#!/usr/bin/env bash
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

# Set directory variables
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
DSS_DIR="${SCRIPT_DIR}/.."
ARTIFACTS_DIR="${DSS_DIR}/../artifacts"

# Build nkv-sdk all w/ kdd-samsung-remote. Use local nkv-openmpdk repo for patch
pushd "${SCRIPT_DIR}/../nkv-sdk/scripts"
    git fetch --tags
    ./build_all.sh kdd-samsung-remote -p "${DSS_DIR}/nkv-openmpdk/"
popd

# Create artifacts dirs
mkdir -p "${ARTIFACTS_DIR}"

# Set artifacts build directory paths
target_build_dir="${DSS_DIR}/nkv-sdk/df_out"
host_build_dir="${DSS_DIR}/nkv-sdk/host_out"
nkv_agent_build_dir="${DSS_DIR}/nkv-sdk/ufm/agents/nkv_agent"
ufm_build_dir="${DSS_DIR}/nkv-sdk/ufm/fabricmanager"
ufm_broker_build_dir="${DSS_DIR}/nkv-sdk/ufm/ufm_msg_broker"

# Remove existing artifacts from Ansible artifact directory
echo "Removing existing artifacts from artifacts directory"
pushd "${ARTIFACTS_DIR}"
    rm -f nkv-target-*.tgz
    rm -f nkv-sdk-bin-*.tgz
    rm -f nkvagent-*.rpm
    rm -f ufm-*.rpm
    rm -f ufmbroker-*.rpm
popd

echo "Copying artifacts to artifacts directory"
# Copy target tarball
pushd "${target_build_dir}"
    cp nkv-target-*.tgz "${ARTIFACTS_DIR}"
popd

# Copy host tarball
pushd "${host_build_dir}"
    cp nkv-sdk-bin-*.tgz "${ARTIFACTS_DIR}"
popd

# Copy NKV Agent RPM
pushd "${nkv_agent_build_dir}"
    cp nkvagent-*.rpm "${ARTIFACTS_DIR}"
popd

# Copy UFM RPM
pushd "${ufm_build_dir}"
    cp ufm-*.rpm "${ARTIFACTS_DIR}"
popd

# Copy UFM Broker RPM
pushd "${ufm_broker_build_dir}"
    cp ufmbroker-*.rpm "${ARTIFACTS_DIR}"
popd
