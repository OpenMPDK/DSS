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

# Set path vars used by all build scripts
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
DSS_DIR=$(realpath "$SCRIPT_DIR/..")
export DSS_DIR
export AWS_SPEC_FILE="$SCRIPT_DIR/aws-sdk-cpp.spec"
export RPMBUILD_DIR="$HOME/rpmbuild"
export RPM_DIR="$RPMBUILD_DIR/RPMS"
export ANSIBLE_DIR="$DSS_DIR/dss-ansible"
export ARTIFACTS_DIR="$ANSIBLE_DIR/artifacts"
export DSS_ECOSYSTEM_DIR="$DSS_DIR/dss-ecosystem"
export DSS_CLIENT_DIR="$DSS_ECOSYSTEM_DIR/dss_client"
export DATAMOVER_DIR="$DSS_DIR/nkv-datamover"
export DSS_SDK_DIR="$DSS_DIR/dss-sdk"
export BUILD_STAGING_DIR="$HOME/workspace"
export MINIO_DIR="$DSS_DIR/dss-minio"

set -e

# Check submodules for git init and checkout recursive if not
checksubmodules()
{
    echo 'Checking submodules for init...'
    SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
    DSS_DIR=$(realpath "$SCRIPT_DIR/..")

    # Get list of repository paths from .gitmodules
    mapfile -t REPOS < <(grep -oP "path = \K.+" "$DSS_DIR/.gitmodules")

    # Fetch tags
    for REPO in "${REPOS[@]}"
    do
        echo "Checking $REPO"
        if [ ! -e "$DSS_DIR/$REPO/.git" ]
        then
            pushd "$DSS_DIR"
                echo "$REPO not init"
                git submodule update --init --recursive
                break
            popd
        else
            echo "$REPO already checked out."
        fi
    done
}

# Print a message to console and return non-zero
die()
{
    echo "$*"
    exit 1
}

# Compare two version strings
vercomp () {
    if [[ "$1" == "$2" ]]
    then
        return 0
    fi
    local IFS=.
    # shellcheck disable=SC2206
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# Test two version strings
testvercomp () {
    vercomp "$1" "$2"
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac
    if [[ "$op" != "$3" ]]
    then
        return 1
    else
        return 0
    fi
}
