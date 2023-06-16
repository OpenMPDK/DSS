FROM centos:centos7.8.2003
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

COPY dss-ansible/artifacts/dss-gcc510-*.rpm ./
COPY dss-ansible/artifacts/aws-sdk-cpp-*.rpm ./
RUN set -eux \
    && yum install -y \
        epel-release \
        centos-release-scl-rh && \
    yum install -y \
        bc \
        bison \
        boost-devel \
        cmake \
        cmake3 \
        CUnit-devel \
        devtoolset-11 \
        dpkg \
        elfutils-libelf-devel \
        flex \
        gcc \
        gcc-c++ \
        git \
        glibc-devel \
        gmp-devel \
        jemalloc-devel \
        Judy-devel \
        libaio-devel \
        libcurl-devel \
        libmpc-devel \
        libuuid-devel \
        man-db \
        meson \
        mpfr-devel \
        ncurses-devel \
        numactl-devel \
        openssl-devel \
        patch \
        pulseaudio-libs-devel \
        python3 \
        python3-devel \
        python3-pip \
        rdma-core-devel \
        redhat-lsb-core \
        rpm-build \
        snappy-devel \
        tbb-devel \
        wget \
        zlib-devel \
        /dss-gcc510*.rpm \
        /aws-sdk-cpp*.rpm && \
    rm -f ./*.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    chmod -R 0777 /var/lib/rpm/ && \
    mkdir /var/cache/yum && \
    chmod 0777 /var/cache/yum && \
    mkdir /.cache && \
    chmod 0777 /.cache && \
    python3 -m pip install --no-cache-dir --upgrade --no-compile pip && \
    python3 -m pip install --no-cache-dir --no-compile pip \
        "ansible>=2.9,<2.10" \
        ansible-lint==5.3.2 \
        gcovr==5.0 \
        pybind11 \
        pycodestyle==2.8.0 \
        shellcheck-py==0.8.0.3 && \
    find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf && \
    find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf && \
    git config --global user.email "docker@msl.lab" && \
    git config --global user.name "Docker Build" && \
    cp /root/.gitconfig / && \
    wget https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && \
    unzip build-wrapper-linux-x86.zip && \
    rm -rf build-wrapper-linux-x86.zip && \
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip && \
    unzip sonar-scanner-cli-4.8.0.2856-linux.zip && \
    rm -rf sonar-scanner-cli-4.8.0.2856-linux.zip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws
ENV PATH="$PATH:$GEM_HOME/bin:/build-wrapper-linux-x86:/sonar-scanner-4.8.0.2856-linux/bin"
ENV PYTHONWARNINGS=ignore::UserWarning
COPY scripts/stagemergeartifacts.sh /
WORKDIR /DSS
