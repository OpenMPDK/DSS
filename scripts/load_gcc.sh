#!/usr/bin/env bash
# shellcheck disable=SC1090
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

# Load GCC for DSS build an runtime environment
set -e

# Load utility functions
. "./$SCRIPT_DIR/utils.sh"

# Minimum and Maximum GCC versions
GCCMINVER=5.1.0
GCCMAXVER=5.5.0

# GCC Setenv scripts for CentOS
GCCSETENV='/usr/local/bin/setenv-for-gcc510.sh'

# Load GCC 5.1.0 paths if the GCCSETENV script is present
if test -f "$GCCSETENV"
then
    . $GCCSETENV
fi

# Check gcc version
GCCVER=$(gcc --version | grep -oP '^gcc \([^)]+\) \K[^ ]+')

# Validate GCC version is supported
if testvercomp "$GCCVER" "$GCCMINVER" '<' || testvercomp "$GCCVER" "$GCCMAXVER" '>'
then
    die "ERROR - Found GCC version: $GCCVER. Must be between $GCCMINVER and $GCCMAXVER."
else
    echo "Supported GCC version found: $GCCVER"
fi
