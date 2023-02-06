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

# Build GCC for DSS build / runtime
set -e

# Load utility functions
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
. "$SCRIPT_DIR/utils.sh"

# Set build variables
GCC_REPO="https://github.com/BobSteagall/gcc-builder"
GCC_REPONAME=$(basename "$GCC_REPO")
GCC_BRANCH="gcc5"
GCC_VERSION="5.1.0"
GCC_DIR="$BUILD_STAGING_DIR/$GCC_REPONAME"

# Check for submodules in update init recursive if missing
checksubmodules

# Create BUILD_STAGING_DIR if it doesn't exist
if [ ! -d "$BUILD_STAGING_DIR" ]
then
    mkdir "$BUILD_STAGING_DIR"
fi

# Clone gcc-builder repo
pushd "$BUILD_STAGING_DIR"
    if [ ! -d "$GCC_REPONAME" ]
    then
        git clone --single-branch --branch "$GCC_BRANCH" "$GCC_REPO"
    fi
popd

# Check if GCC RPM already built
CHECK_GCC_RPM=$(find "$GCC_DIR/packages" -name '*.rpm' | wc -l)

# Only build GCC RPM if not already built
if [ "$CHECK_GCC_RPM" == 0 ]
then
    # Build GCC
    pushd "$GCC_DIR"
        sed -i "s/^\(export GCC_VERSION=\)5.X.0$/\1$GCC_VERSION/" gcc-build-vars.sh
        sed -i "s/^\(export GCC_BUILD_THREADS_ARG=\)'-j8'$/\1'-j$(nproc)'/" gcc-build-vars.sh
        sed -i "s/KEWB Computing Build/Samsung R\&D/" gcc-build-vars.sh
        sed -i "s/^\(export GCC_CUSTOM_BUILD_STR=\)kewb$/\1dss/" gcc-build-vars.sh
        sed -i "s/^\(Name:       \)kewb-gcc/\1dss-gcc/" gcc.spec
        sed -i "s/^\(Vendor:     \)KEWB Enterprises/\1Samsung R\&D/" gcc.spec
        sed -i "s/build by KEWB/build by Samsung R\&D/" gcc.spec
        sed -i "s/_build_name_fmt %%{NAME}-%%{RELEASE}/_build_name_fmt %%{NAME}-%%{VERSION}-%%{RELEASE}/" make-gcc-rpm.sh
        ./clean-gcc.sh
        ./build-gcc.sh -T | tee build.log
        ./stage-gcc.sh
        ./make-gcc-rpm.sh -v
    popd
else
    echo 'GCC RPM already built. Skipping...'
fi

echo 'Copying GCC RPM to Ansible artifacts...'
find "$GCC_DIR/packages" -name '*.rpm' -exec cp {} "$ARTIFACTS_DIR" \;

