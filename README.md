# DSS

Disaggregated Storage Solution

## What is DSS

Samsung has developed DSS, a rack-scalable, very high read-bandwidth-optimized, Amazon S3-compatible object storage solution. It utilizes a disaggregated architecture, enabling independent scaling of storage and compute. It features an end-to-end KV semantic communication stack, entirely eliminating the legacy software storage stack. All storage communication uses the NVMeOf-KV-RDMA protocol introduced and open sourced by Samsung. With zero-copy transfer, it achieves high end-to-end performance. The DSS client-side stack includes a high performance wrapper library for simple application integration. Applications utilizing the DSS client library eliminate the need for bucket semantics, key distribution and load balancing between server-side S3 endpoints.

## Prerequisites

### Operating system requirements

DSS build and runtime is presently supported on CentOS 7.8.

### Build package dependencies

Install the folling packages / modules to build DSS and its external dependencies:

```bash
sudo yum install epel-release -y
sudo yum group install "Development Tools" -y
sudo yum install bc boost-devel check cmake cmake3 dejagnu dpkg elfutils-libelf-devel expect glibc-devel \
  jemalloc-devel Judy-devel libaio-devel libcurl-devel libuuid-devel meson ncurses-devel numactl-devel \
  openssl-devel pulseaudio-libs-devel python3 python3-devel python3-pip rdma-core-devel redhat-lsb ruby-devel \
  snappy-devel tbb-devel wget zlib-devel -y
sudo python3 -m pip install pybind11
sudo gem install ffi -v 1.12.2
sudo gem install git -v 1.6.0
sudo gem install rb-inotify -v 0.9.10
sudo gem install rexml -v 3.2.3
sudo gem install backports -v 3.21.0
sudo gem install fpm
```

## Build DSS

**NOTE: User-built GCC and AWS-SDK-CPP RPMs must be installed on the build machine.**

On initial build:

1. Build GCC
2. Install the resulting GCC RPM
3. Build AWS-SDK-CPP
4. Install the resulting AWS-SDK-CPP RPM.
5. Run the `build_all.sh` script

```bash
./scripts/build_gcc.sh
sudo yum install ./dss-ansible/artifacts/dss-gcc510*.rpm -y
./scripts/builds_aws-sdk.sh
sudo yum install ./dss-ansible/artifacts/aws-sdk-cpp-1.8.99-0.x86_64.rpm -y
./scripts/build_all.sh
```

Once the GCC and AWS RPMs are installed, only the `build_all.sh` script needs to be run on subsequent builds.

Dependency artifacts for GCC, kernel, aws-sdk-cpp, and mlnx-tools are staged under `rpmbuilder` and `workspace` directories of your home directory by default. By leaving them in-place, re-build of these upstream components will be skipped on subsequent builds.

### Optional: Build individual components

DSS Dependency build scripts:

* Build GCC: `./scripts/build_gcc.sh`
* Build aws-sdk-cpp: `./scripts/build_aws-sdk.sh`
* Build kernel: `./scripts/build_kernel.sh`
* Build mlnx-tools: `./scripts/build_mlnx-tools.sh`

DSS individual components:

* Build dss-sdk: `./scripts/build_dss-sdk.sh`
* Build dss-minio: `./scripts/build_minio.sh`
* Build dss-client: `./scripts/build_client.sh`
* Build dss-datamover: `./scripts/build_datamover.sh`

## Deploy DSS

See [dss-ansible README](https://github.com/OpenMPDK/dss-ansible/blob/master/README.md)
