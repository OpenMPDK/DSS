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

# Build mlnx-tools and mft for DSS runtime
set -e

# Load utility functions
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
. "$SCRIPT_DIR/utils.sh"

# Set build variables
MLNX_STAGING_DIR="$HOME/workspace"
MFT_URL='https://content.mellanox.com/MFT/mft-4.17.0-106-x86_64-rpm.tgz'
MLNX_TOOLS_URL='https://github.com/Mellanox/mlnx-tools'
MLNX_TOOLS_NAME=$(basename "$MLNX_TOOLS_URL")
MLNX_TOOLS_BRANCH='mlnx_ofed'

# Check for submodules in update init recursive if missing
checksubmodules

# Create GCC_STAGING_DIR if it doesn't exist
if [ ! -d "$MLNX_STAGING_DIR" ]
then
    mkdir "$MLNX_STAGING_DIR"
fi

# Download mft to Mellanox staging directory if not present
if [ ! -f "$MLNX_STAGING_DIR/$(basename $MFT_URL)" ]
then
    pushd "$MLNX_STAGING_DIR"
        curl -O "$MFT_URL"
    popd
else
    echo "mft RPM already downloaded. Skipping..."
fi

# Check if GCC RPM already built
CHECK_MLNX_TOOLS_RPM=$(find "$RPM_DIR" -name 'mlnx-tools*.rpm' | wc -l)

# Build mlnx-tools rpm if not present
if [ "$CHECK_MLNX_TOOLS_RPM" == 0 ]
then
    # Build mlnx-tools
    pushd "$MLNX_STAGING_DIR"
        if [ ! -d "$MLNX_TOOLS_NAME" ]
        then
            git clone --single-branch --branch "$MLNX_TOOLS_BRANCH" "$MLNX_TOOLS_URL"
        fi

        # Create source tarball
        TOOLSVERSION=$(grep -oP "Version: \K.+" "$MLNX_TOOLS_NAME"/mlnx-tools.spec)
        SRCTAR="$MLNX_TOOLS_NAME-$TOOLSVERSION.tar.gz"
        tar czvf "$SRCTAR" "$MLNX_TOOLS_NAME" --transform "s/$MLNX_TOOLS_NAME/$MLNX_TOOLS_NAME-$TOOLSVERSION/"
        mv "$SRCTAR" "$RPMBUILD_DIR/SOURCES"

        pushd "$MLNX_TOOLS_NAME"
            # Use python3 for CentOS 7 or newer - so resulting RPM works on both CentOS 7 and 8 (Stream)
            sed -i "s/^\(%global RHEL8 0%{?rhel} >= \)7/\18/" mlnx-tools.spec
            rpmbuild -ba mlnx-tools.spec
        popd
    popd
else
    echo "mlnx-tools RPM already built. Skipping..."
fi

echo 'Copying mft RPM to Ansible artifacts...'
cp "$MLNX_STAGING_DIR/$(basename $MFT_URL)" "$ARTIFACTS_DIR"

echo 'Copying mlnx-tools RPM to Ansible artifacts...'
find "$RPM_DIR" -name 'mlnx-tools-*.rpm' -exec cp {} "$ARTIFACTS_DIR/" \;
