set -e && \
sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/*.repo && \
sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/*.repo && \
sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/*.repo && \
yum install epel-release centos-release-scl-rh -y && \
yum install bc bison boost-devel cmake cmake3 CUnit-devel devtoolset-11 dpkg elfutils-libelf-devel \
  flex gcc gcc-c++ git glibc-devel gmp-devel jemalloc-devel Judy-devel libaio-devel libcurl-devel libmpc-devel \
  libuuid-devel make man-db meson mpfr-devel ncurses-devel numactl-devel openssl openssl-devel patch \
  pulseaudio-libs-devel python3 python3-devel python3-pip rdma-core-devel redhat-lsb-core rpm-build \
  snappy-devel tbb-devel wget zlib-devel dnf -y && \
dnf install cppunit-devel -y && \
python3 -m pip install pybind11 gcovr==5.0 
# && \
# wget https://go.dev/dl/go1.23.4.linux-amd64.tar.gz && \
# rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz && \
# export PATH=$PATH:/usr/local/go/bin && go version

# Set Go variables
# Set path variables
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
GIT_DIR=$(realpath "$SCRIPT_DIR/..")
GOVER='1.12'
GODIR="$GIT_DIR/go_$GOVER"
# echo $GODIR
GOTGZ="go$GOVER.linux-amd64.tar.gz"
GOURL="https://dl.google.com/go/$GOTGZ"
GITHUBDIR='github.com/minio'
MINIODIR='minio'
export GO111MODULE=off
export GOPATH="$GODIR"
export PATH="$PATH:$GODIR/bin"

echo 'Downloading go'
if [ ! -d "$GODIR" ]; then
    mkdir "$GODIR"
    if [ ! -e "./$GOTGZ" ]; then
        wget "$GOURL" --no-check-certificate
    fi
    tar xzf "$GOTGZ" -C "$GODIR" --strip-components 1
    rm -f "$GOTGZ"
fi

go version