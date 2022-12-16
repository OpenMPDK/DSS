set -e

GIT_AWS_RELEASE=1.9
SCRIPT_DIR=$(realpath ${PWD}/$(dirname $0))
TOP_DIR=${PWD}/aws-build-$(date +%s)/
INSTALL_DIR=${TOP_DIR}/BUILDROOT/aws-sdk-cpp-${GIT_AWS_RELEASE}-0.x86_64/usr/local
AWS_SPEC_FILE="aws-${GIT_AWS_RELEASE}.spec"
AWS_DIR="aws-git-${GIT_AWS_RELEASE}"
GIT_CHECKOUT_TAG="1.9.343-elbencho-tag"

#Cleanup old directories
rm -rf $TOP_DIR
rm -rf $AWS_DIR

mkdir -p $INSTALL_DIR

# Do git clone and build
#git clone --recurse-submodules https://github.com/aws/aws-sdk-cpp.git ${AWS_DIR}
#git checkout release/${GIT_AWS_RELEASE}
git clone --recursive https://github.com/breuner/aws-sdk-cpp.git ${AWS_DIR}
git checkout ${GIT_CHECKOUT_TAG}

pushd ${AWS_DIR}

# Apply patches for building AWS
patch -p1 < ${SCRIPT_DIR}/aws-git-${GIT_AWS_RELEASE}.patch

# Compiling the code
source /opt/rh/devtoolset-8/enable
cd crt/aws-crt-cpp
cmake3 . -DBUILD_SHARED_LIBS=ON -DCPP_STANDARD=17 -DAUTORUN_UNIT_TESTS=OFF -DENABLE_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DBYO_CRYPTO=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} && make -j $(nproc) install
cd ../..
cmake3 . -DBUILD_ONLY="s3;transfer" -DBUILD_SHARED_LIBS=ON -DCPP_STANDARD=17 -DAUTORUN_UNIT_TESTS=OFF -DENABLE_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DBYO_CRYPTO=ON -DBUILD_DEPS=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} && make -j $(nproc) install
popd

# Create spec file for RPM build
cat > ${AWS_SPEC_FILE} << EOF
Name:           aws-sdk-cpp
Version:        ${GIT_AWS_RELEASE}
Release:        0
Summary:        Amazon Web Services SDK for C++
License:        ASL 2.0
URL:            https://github.com/aws/%{name}


%define _unpackaged_files_terminate_build 0

%description
The Amazon Web Services (AWS) SDK for C++ provides a modern C++ interface for
AWS. It is meant to be performant and fully functioning with low- and
high-level SDKs, while minimizing dependencies and providing platform
portability (Windows, OSX, Linux, and mobile).

%files
/usr/local/lib64/*
/usr/local/include/*

EOF

# Build AWS RPM
echo "Building AWS RPM ...."
rpmbuild --define "_topdir ${TOP_DIR}" -bb ${AWS_SPEC_FILE} 

