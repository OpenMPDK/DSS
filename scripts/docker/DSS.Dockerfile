FROM centos:centos7.8.2003

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
		ruby-devel \
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
    python3 -m pip install pybind11 && \
    gem install --no-ri --no-rdoc --conservative --user-install --minimal-deps \
        dotenv:2.7.6 \
        cabin:0.9.0 \
        arr-pm:0.0.11 \
        ffi:1.12.2 \
        rchardet:1.8.0 \
        git:1.7.0 \
        rexml:3.2.4 \
        backports:3.21.0 \
        clamp:1.0.1 \
        mustache:0.99.8 \
        stud:0.0.23 \
        insist:1.0.0 \
        pleaserun:0.0.32 \
        fpm:1.13.1 && \
    mv /root/.gem / && \
    chmod -R 0777 /.gem && \
    git config --global user.email "docker@msl.lab" && \
    git config --global user.name "Docker Build" && \
    cp /root/.gitconfig / && \
    wget https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && \
    unzip build-wrapper-linux-x86.zip && \
    rm -rf build-wrapper-linux-x86.zip && \
    wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip && \
    unzip sonar-scanner-cli-4.7.0.2747-linux.zip && \
    rm -rf sonar-scanner-cli-4.7.0.2747-linux.zip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf ./aws
ENV GEM_HOME="/.gem/ruby"
ENV PATH="$PATH:$GEM_HOME/bin:/build-wrapper-linux-x86:/sonar-scanner-4.7.0.2747-linux/bin"
COPY scripts/stagemainartifacts.sh /
COPY scripts/getminiodeps.sh /
WORKDIR /DSS
