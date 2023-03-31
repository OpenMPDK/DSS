#!/usr/bin/bash
set -e

GIT_AWS_RELEASE=1.9
AWS_SPEC_FILE="aws-${GIT_AWS_RELEASE}.spec"
GIT_CHECKOUT_TAG="1.9.343-elbencho-tag"

cp aws-git-${GIT_AWS_RELEASE}.patch $HOME/rpmbuild/SOURCES/


# Create spec file for RPM build
cat > ${AWS_SPEC_FILE} << EOF
Name:           aws-sdk-cpp
Version:        ${GIT_AWS_RELEASE}
Release:        0
Summary:        Amazon Web Services SDK for C++
License:        ASL 2.0
URL:            https://github.com/aws/%{name}
Patch0:		aws-git-${GIT_AWS_RELEASE}.patch


%define _unpackaged_files_terminate_build 0

%description
The Amazon Web Services (AWS) SDK for C++ provides a modern C++ interface for
AWS. It is meant to be performant and fully functioning with low- and
high-level SDKs, while minimizing dependencies and providing platform
portability (Windows, OSX, Linux, and mobile).

%prep
rm -rf aws-sdk-cpp
git clone --recursive -q https://github.com/breuner/aws-sdk-cpp.git 
cd aws-sdk-cpp
git checkout ${GIT_CHECKOUT_TAG}

%patch0 -p1

%build
# Compiling the code
source /opt/rh/devtoolset-11/enable
cd %{_builddir}/aws-sdk-cpp/crt/aws-crt-cpp
cmake3 . -DBUILD_SHARED_LIBS=ON -DCPP_STANDARD=17 -DAUTORUN_UNIT_TESTS=OFF -DENABLE_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DBYO_CRYPTO=ON -DCMAKE_INSTALL_PREFIX=%{buildroot}/usr/local/ && make -j $(nproc) install
cd ../..
cmake3 . -DBUILD_ONLY="s3;transfer" -DBUILD_SHARED_LIBS=ON -DCPP_STANDARD=17 -DAUTORUN_UNIT_TESTS=OFF -DENABLE_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DBYO_CRYPTO=ON -DBUILD_DEPS=OFF -DCMAKE_INSTALL_PREFIX=%{buildroot}/usr/local/ && make -j $(nproc) install

%files
/usr/local/lib64/*
/usr/local/include/*

EOF

# Build AWS RPM
echo "Building AWS RPM ...."
rpmbuild -bb ${AWS_SPEC_FILE} 

