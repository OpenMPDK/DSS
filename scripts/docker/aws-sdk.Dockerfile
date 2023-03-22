# syntax=docker/dockerfile:1

FROM centos:centos7.8.2003
RUN set -eux \
	&& yum install -y \
        epel-release  \
        centos-release-scl-rh && \
    yum install -y \
        boost-devel \
        cmake3 \
        devtoolset-11 \
        git \
        libcurl-devel \
        openssl-devel \
        rpm-build && \
    yum clean all && \
    rm -rf /var/cache/yum
WORKDIR /aws-sdk
