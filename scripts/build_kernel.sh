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

# Build Kernel for DSS runtime
set -e

# Set path variables
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
KERNEL_CONFIG="$SCRIPT_DIR/kernel_config"
KERNEL_URL="https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.1.tar.gz"
KERNEL_TGZ=$(basename $KERNEL_URL)
KERNEL_NAME=$(basename $KERNEL_URL .tar.gz)
KERNEL_DIR="$HOME/workspace"

# Download kernel source tarball
pushd "$KERNEL_DIR"
    if [ ! -d "$KERNEL_NAME" ]
    then
        curl "$KERNEL_URL" --output "$KERNEL_TGZ"
        tar xvfz "./$KERNEL_TGZ"
        rm -f "./$KERNEL_TGZ"
    fi
popd

pushd "$KERNEL_DIR/$KERNEL_NAME"
    # Copy kernel config file
    cp "${KERNEL_CONFIG}" .config

    # Make kernel RPMs
    make clean
    make "-j$(nproc)" rpm-pkg
popd
