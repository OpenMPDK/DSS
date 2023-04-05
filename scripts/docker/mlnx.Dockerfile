# syntax=docker/dockerfile:1

FROM centos:centos7.8.2003
RUN set -eux \
    && yum install -y \
        git \
        make \
        python3-devel \
        rpm-build && \
    yum clean all && \
    rm -rf /var/cache/yum
WORKDIR /mlnx
