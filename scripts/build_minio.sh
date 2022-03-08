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

set -e

# Set path variables
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
DSS_DIR="${SCRIPT_DIR}/../"
ARTIFACTS_DIR="${DSS_DIR}/../artifacts"
LIB_DIR="${DSS_DIR}/nkv-sdk/host_out/lib"
INCLUDE_DIR="${DSS_DIR}/nkv-sdk/host/include"

# Set go variables
GOVER='1.12'
GODIR="${SCRIPT_DIR}/../../go_${GOVER}"
GOTGZ="go${GOVER}.linux-amd64.tar.gz"
GOURL="https://dl.google.com/go/${GOTGZ}"
GITHUBDIR='github.com/minio'
MINIODIR='minio'
MINIOURL="${SCRIPT_DIR}/../nkv-minio"

# Set MinIO Client Variables
MCURL="https://dl.min.io/client/mc/release/linux-amd64/archive/mc.RELEASE.2019-10-09T22-54-57Z"
S3BENCHPATH="${DSS_DIR}/nkv-s3benchmark/s3-benchmark"

# Create artifacts dirs
mkdir -p "${ARTIFACTS_DIR}"

# Remove existing artifacts
pushd "${ARTIFACTS_DIR}"
    rm -f dss-minio-bin-*.tgz minio mc s3-benchmark
popd

echo 'Downloading build deps'
export LD_LIBRARY_PATH="${LIB_DIR}"
export CGO_CFLAGS="-std=gnu99 -I${INCLUDE_DIR}"
export CGO_LDFLAGS="-L${LIB_DIR} -lnkvapi -lsmglog"

echo 'Downloading go'
if [ ! -d "${GODIR}" ]; then
    mkdir "${GODIR}"
    if [ ! -e "./${GOTGZ}" ]; then
        wget "${GOURL}" --no-check-certificate
    fi
    tar xzf "${GOTGZ}" -C "${GODIR}" --strip-components 1
    rm -f "${GOTGZ}"
fi

echo 'Checkout and build minio'
pushd "${GODIR}/src"
    mkdir -p "${GITHUBDIR}"

    pushd "${GITHUBDIR}"
        # Remove existing minio repo
        rm -rf "${MINIODIR}"

        # Build MinIO
        git clone --progress "${MINIOURL}" "${MINIODIR}"
        pushd "${MINIODIR}"
            echo 'Building minio server'
            "${GODIR}"/bin/go build
            cp minio "${ARTIFACTS_DIR}"

            # Get release string
            git fetch --tags
            RELEASESTRING=$(git describe --tags --exact-match || git rev-parse --short HEAD)
        popd
    popd
popd

pushd "${ARTIFACTS_DIR}"
    # Download MinIO client binaries
    wget -O mc "${MCURL}"
    cp "${S3BENCHPATH}" .

    # Set executable
    chmod +x mc s3-benchmark

    # Create release tarball
    tar czvf "dss-minio-bin-${RELEASESTRING}.tgz" minio mc s3-benchmark
    rm -f minio mc s3-benchmark
popd
