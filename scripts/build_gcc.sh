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

# Build GCC for DSS build / runtime
set -e

# Set path variables
GCC_REPO="https://github.com/BobSteagall/gcc-builder"
GCC_BRANCH="gcc5"
GCC_VERSION="5.1.0"
GCC_DIR="$HOME/workspace"

# Create GCC_DIR if it doesn't exist
if [ ! -d "$GCC_DIR" ]
then
    mkdir "$GCC_DIR"
fi

# Clone gcc-builder repo
pushd "$GCC_DIR"
    if [ ! -d "$(basename $GCC_REPO)" ]
    then
        git clone --single-branch --branch "$GCC_BRANCH" "$GCC_REPO"
    fi
popd

# Build GCC
pushd "$GCC_DIR/$(basename "$GCC_REPO")"
    sed -i "s/^export GCC_VERSION=5.X.0$/export GCC_VERSION=$GCC_VERSION/" gcc-build-vars.sh
    sed -i "s/^export GCC_BUILD_THREADS_ARG='-j8'$/export GCC_BUILD_THREADS_ARG='-j$(nproc)'/" gcc-build-vars.sh
    ./clean-gcc.sh
    ./build-gcc.sh | tee build.log
    ./stage-gcc.sh
    ./make-gcc-rpm.sh -v
popd
