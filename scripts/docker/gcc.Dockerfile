# syntax=docker/dockerfile:1

FROM centos:centos7.8.2003
RUN set -eux \
	&& yum install -y \
        epel-release && \
    yum install -y \
        gcc \
        gcc-c++ \
        git \
        make \
        redhat-lsb-core \
        rpm-build \
        wget \
        zlib-devel && \
    yum clean all && \
    rm -rf /var/cache/yum
WORKDIR /gcc
