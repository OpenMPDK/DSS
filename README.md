# DSS

Disaggregated Storage Software

DSS build and runtime is supported on CentOS 7.8.

## What is DSS

etc

## Prerequisites

* GCC 5.1.0
  * Install required yum packages to build GCC:

    ```bash
    sudo yum group install "Development Tools" -y
    sudo yum install redhat-lsb rpm-build rpm-sign check dejagnu expect -y
    ```

  * Build with `./scripts/build_gcc.sh` script
    * Resulting RPM is staged under `dss-ansible/artifacts` for deployment
    * Install resulting GCC RPM to build DSS and dependent components (`aws-sdk-cpp`)
    * Alternatively, use `https://github.com/BobSteagall/gcc-builder` to manually build and install GCC 5.1.0 RPM
* aws-sdk-cpp 1.8.99
  * Install required yum packages to build aws-sdk-cpp:

    ```bash
    sudo yum group install "Development Tools" -y
    sudo yum install redhat-lsb rpm-build rpm-sign check dejagnu expect -y
    ```

  * Build with `./scripts/build_aws-sdk.sh` script
    * Resulting RPM is staged under `dss-ansible/artifacts` for deployment
    * Alternatively, use `https://github.com/aws/aws-sdk-cpp/releases/tag/1.8.99` to manually build and install aws-sdk-cpp
      * Build RPM using GCC 5.1.0 (Use custom spec file `./scripts/aws-sdk-cpp.spec`)
* Kernel 5.1
  * Required to deploy for runtime on disaggregated storage nodes
  * Install required yum packages to build kernel:

    ```bash
    sudo yum install ncurses-devel make gcc bc openssl-devel rpm-build flex bison elfutils-libelf-devel -y
    ```

  * Build with `./scripts/build_kernel.sh` script
    * Resulting RPMs are staged under `dss-ansible/artifacts` for deployment
  * Alternatively, use `https://github.com/torvalds/linux/releases/tag/v5.1` to manually build Kernel 5.1
    * Use custom .config file (`./scripts/kernel_config`)

### DSS Build Dependencies - YUM modules

Install the following yum packages to build DSS:

```bash
sudo yum group install "Development Tools" -y
sudo yum install epel-release -y
sudo yum install bison boost-devel check cmake cmake3 \
  dejagnu dpkg elfutils-libelf-devel expect flex gcc gcc-c++ \
  git glibc-devel jemalloc-devel Judy-devel libaio-devel \
  libcurl-devel libuuid-devel make meson ncurses-devel \
  numactl-devel openssl-devel pulseaudio-libs-devel python3 \
  python3-devel python3-pip rdma-core-devel redhat-lsb \
  rpm-build rpm-sign ruby-devel snappy-devel tbb-devel wget \
  zlib-devel -y
```

### DSS Build Dependencies - Python modules

Install the following python modules to build DSS:

```bash
sudo python3 -m pip install pybind11
```

### DSS Build Dependencies - Ruby modules

Install the following ruby modules to build DSS:

```bash
sudo gem install ffi -v 1.12.2
sudo gem install git -v 1.7.0
sudo gem install rexml -v 3.2.4
sudo gem install fpm
```

## Build DSS

Use `git clone --recursive` to check out the DSS repo and all of its submodules.

Build each component in the order listed:

`./scripts/build_dss-sdk.sh`

`./scripts/build_minio.sh`

`./scripts/build_client.sh`

`./scripts/build_datamover.sh`

## Deploy DSS

See [dss-ansible README](./dss-ansible/README.md)
