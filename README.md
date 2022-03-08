# DSS

Disaggregated Storage Software

## Prerequisites

* GCC 5.1.0
  * Build with `./scripts/build_gcc.sh` script
    * Alternatively, use `https://github.com/BobSteagall/gcc-builder` to manually build and install GCC 5.1.0 RPM
  * Keep RPM file to use for release artifacts (see `GCC_RPM` var, in `scripts/build_release_tarball.sh`)
* aws-sdk-cpp 1.8.99
  * Build with `./scripts/build_aws-sdk.sh` script
    * Requires `rpmbuild`:

      ```bash
        sudo yum install rpmbuild -y
      ```

    * Alternatively, use `https://github.com/aws/aws-sdk-cpp/releases/tag/1.8.99` to manually build and install aws-sdk-cpp
    * Build RPM using GCC 5.1.0 (Use custom spec file `./scripts/aws-sdk-cpp.spec`)
  * Keep RPM file to use for release artifacts (see `GCC_RPM` var, in `scripts/build_release_tarball.sh`)
* Kernel 5.1
  * Build with `./scripts/build_kernel.sh` script
  * Alternatively, use `https://github.com/torvalds/linux/releases/tag/v5.1` to manually build Kernel 5.1
    * Use custom .config file (`./scripts/kernel_config`)
  * Keep RPM files to use for release artifacts (see `KERNEL` vars, in `scripts/build_release_tarball.sh`)

### DSS Build Dependencies - YUM modules

`sudo yum group install "Development Tools" -y`

`sudo yum install epel-release -y`

`sudo yum install bison boost-devel check cmake cmake3 dejagnu dpkg elfutils-libelf-devel expect flex gcc gcc-c++ git glibc-devel jemalloc-devel Judy-devel libaio-devel libcurl-devel libuuid-devel make meson ncurses-devel numactl-devel openssl-devel pulseaudio-libs-devel python3 python3-devel python3-pip rdma-core-devel redhat-lsb rpm-build rpm-sign ruby-devel snappy-devel tbb-devel wget zlib-devel -y`

### DSS Build Dependencies - Python modules

`sudo python3 -m pip install pybind11`

### DSS Build Dependencies - Ruby modules

`sudo gem install ffi -v 1.12.2`

`sudo gem install git -v 1.7.0`

`sudo gem install rexml -v 3.2.4`

`sudo gem install fpm`

## Build DSS

Use `git clone --recursive` to check out the DSS repo and all of its submodules.

Build each component in order listed:

`./scripts/build_nkv-sdk.sh`

`./scripts/build_minio.sh`

`./scripts/build_client.sh`

`./scripts/build_ai_benchmark.sh`

`./scripts/build_datamover.sh`
