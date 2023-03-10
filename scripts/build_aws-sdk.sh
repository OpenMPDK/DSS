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

# Build aws-sdk for DSS build / runtime
set -e

# Load utility functions
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
. "$SCRIPT_DIR/utils.sh"

# Set build variables
AWS_SPEC_FILE="$SCRIPT_DIR/aws-sdk-cpp.spec"

# Check for submodules in update init recursive if missing
checksubmodules

# Check if aws-sdk-cpp RPM already built
CHECK_AWS_RPM=$(find "$RPM_DIR" -name 'aws-sdk-cpp*.rpm' | wc -l)

# Only build aws-sdk-cpp RPM if not already built
if [ "$CHECK_AWS_RPM" == 0 ]
then
    # Load GCC
    . "$SCRIPT_DIR/load_gcc.sh"

    # Build aws-sdk-cpp
    rpmbuild -ba "$AWS_SPEC_FILE"
else
    echo 'aws-sdk-cpp RPM already built. Skipping...'
fi

echo 'Copying aws-sdk-cpp RPM to dss-ansible artifacts directory...'
find "$RPM_DIR" -name 'aws-sdk-cpp*.rpm' -exec cp {} "$ARTIFACTS_DIR/" \;