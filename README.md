# DSS

Disaggregated Storage Solution

## What is DSS

DSS is a rack-scalable, very high read-bandwidth-optimized, Amazon S3-compatible object storage solution developed by Samsung. It utilizes a disaggregated architecture, enabling independent scaling of storage and compute. It features an end-to-end KV semantic communication stack, entirely eliminating the legacy software storage stack. All storage communication uses the NVMeOf-KV-RDMA protocol introduced and open sourced by Samsung. With zero-copy transfer, it achieves high end-to-end performance. The DSS client-side stack includes a high performance wrapper library for simple application integration. Applications utilizing the DSS client library eliminate the need for bucket semantics, key distribution and load balancing between server-side S3 endpoints.

[![How to build, deploy, and use DSS software](https://img.youtube.com/vi/fpAFvLhTpqw/0.jpg)](https://youtu.be/fpAFvLhTpqw "How to build, deploy, and use DSS software")

[How to build, deploy, and use DSS software](https://youtu.be/fpAFvLhTpqw)

## Build DSS - Docker

DSS is optimally built via Docker using the scripts documented below.

### Build All - Docker

Build all of the DSS artifacts and its dependency artifacts using one script:

```bash
./scripts/docker/build_all.sh
```

### Build Dependencies - Docker

Optionally, build only the dependencies artifacts:

```bash
./scripts/docker/build_gcc.sh
./scripts/docker/build_aws-sdk.sh
./scripts/docker/build_kernel.sh
./scripts/docker/build_mlnx-tools.sh
```

### Build DSS Artifacts - Docker

Optionally, build only the DSS artifacts:

```bash
./scripts/docker/build_dss-sdk.sh
./scripts/docker/build_minio.sh
./scripts/docker/build_dss-client.sh
./scripts/docker/build_datamover.sh
```

## Build DSS

Alternatively, DSS can be built natively, but all dependencies must be installed first.

### Prerequisites

#### Operating system requirements

DSS build and runtime is presently supported on CentOS 7.8.

#### Build package dependencies

Install the following packages / modules to build DSS and its external dependencies:

```bash
sudo yum install epel-release centos-release-scl-rh -y
sudo yum install bc bison boost-devel cmake cmake3 CUnit-devel devtoolset-11 dpkg elfutils-libelf-devel \
  flex gcc gcc-c++ git glibc-devel gmp-devel jemalloc-devel Judy-devel libaio-devel libcurl-devel libmpc-devel \
  libuuid-devel make man-db meson mpfr-devel ncurses-devel numactl-devel openssl openssl-devel patch \
  pulseaudio-libs-devel python3 python3-devel python3-pip rdma-core-devel redhat-lsb-core rpm-build ruby-devel \
  snappy-devel tbb-devel wget zlib-devel -y
sudo python3 -m pip install pybind11 gcovr==5.0
sudo gem install dotenv:2.7.6 cabin:0.9.0 arr-pm:0.0.11 ffi:1.12.2 rchardet:1.8.0 git:1.7.0 rexml:3.2.4 backports:3.21.0 \
  clamp:1.0.1 mustache:0.99.8 stud:0.0.23 insist:1.0.0 pleaserun:0.0.32 fpm:1.13.1
```

**NOTE: User-built GCC and AWS-SDK-CPP RPMs must be installed on the build machine.**

On initial build:

1. Build GCC: `./scripts/build_gcc.sh`
2. Install the resulting GCC RPM: `sudo yum install ./dss-ansible/artifacts/dss-gcc510*.rpm -y`
3. Build AWS-SDK-CPP: `./scripts/build_aws-sdk.sh`
4. Install the resulting AWS-SDK-CPP RPM: `sudo yum install ./dss-ansible/artifacts/aws-sdk-cpp-*.rpm -y`
5. Run the `build_all.sh` script: `./scripts/build_all.sh`

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
* Build dss-client: `./scripts/build_dss-client.sh`
* Build dss-datamover: `./scripts/build_datamover.sh`

## Deploy DSS

See [dss-ansible README](https://github.com/OpenMPDK/dss-ansible/blob/master/README.md)

## Blogs and Papers

[DSS: High I/O Bandwidth Disaggregated Object Storage System for AI Applications](https://www.researchgate.net/publication/358580692_DSS_High_IO_Bandwidth_Disaggregated_Object_Storage_System_for_AI_Applications)

[High-Capacity SSDs for AI/ML using Disaggregated Storage Solution: Performance Test Results Show Promise](https://semiconductor.samsung.com/us/newsroom/tech-blog/high-capacity-ssds-for-ai-ml-using-disaggregated-storage-solution-performance-test-results-show-promise/)
