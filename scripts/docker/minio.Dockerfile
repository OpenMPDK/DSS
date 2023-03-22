# syntax=docker/dockerfile:1

FROM centos:centos7.8.2003
RUN set -eux \
	&& yum install -y \
        git \
        make \
        wget && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    git config --global user.email "docker@msl.lab" && \
    git config --global user.name "Docker Build" && \
    cp /root/.gitconfig / && \
    mkdir /.cache && \
    chmod 0777 /.cache
WORKDIR /minio
