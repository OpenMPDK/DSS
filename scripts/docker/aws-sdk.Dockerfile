# syntax=docker/dockerfile:1

FROM centos:centos7.8.2003
COPY dss-ansible/artifacts/dss-gcc510-*.rpm ./
RUN set -eux \
    && yum install -y \
        epel-release &&  \
    yum install -y \
        boost-devel \
        cmake3 \
        gcc-c++ \
        git \
        libcurl-devel \
        make \
        openssl-devel \
        pulseaudio-libs-devel \
        rpm-build \
        /dss-gcc510*.rpm && \
    rm -f ./*.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum
WORKDIR /aws-sdk
