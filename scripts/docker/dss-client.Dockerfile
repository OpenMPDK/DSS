# syntax=docker/dockerfile:1

FROM centos:centos7.8.2003
COPY dss-ansible/artifacts/aws-sdk-cpp-*.rpm ./
RUN set -eux \
	&& yum install -y \
        epel-release \
        centos-release-scl-rh && \
    yum install -y \
        /aws-sdk-cpp*.rpm \
        cmake3 \
        devtoolset-11 \
        git \
        gmp-devel \
        libcurl-devel \
        libmpc-devel \
        libuuid-devel \
        mpfr-devel \
        openssl-devel \
        pulseaudio-libs-devel \
        python3-devel \
        python3-pip \
        rdma-core-devel \
        zlib-devel && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    python3 -m pip install pybind11

WORKDIR /dss-client
