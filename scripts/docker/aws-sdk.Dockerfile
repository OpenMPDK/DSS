# syntax=docker/dockerfile:1

FROM centos:centos7.8.2003
# Remove below for Gen2
COPY dss-ansible/artifacts/dss-gcc510-*.rpm ./
RUN set -eux \
	&& yum install -y \
        epel-release &&  \
        # Add below for Gen2
        # centos-release-scl-rh && \
    yum install -y \
        boost-devel \
        cmake3 \
        # Add below for Gen2
        # devtoolset-11 \
        git \
        libcurl-devel \
        openssl-devel \
        # Remove below for Gen2
        gcc-c++ \
        make \
        pulseaudio-libs-devel \
        rpm-build \
        /dss-gcc510*.rpm && \
    rm -f ./*.rpm && \
    # Remove above for Gen2
    yum clean all && \
    rm -rf /var/cache/yum
WORKDIR /aws-sdk
