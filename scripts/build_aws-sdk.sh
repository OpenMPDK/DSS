#!/usr/bin/bash
# shellcheck disable=SC1090,SC1091
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/utils.sh"

GIT_AWS_RELEASE=1.9
GIT_CHECKOUT_TAG="1.9.343-elbencho-tag"

echo "Preparing the environment and the spec file"
mkdir -p "$HOME"/rpmbuild/{SOURCES,BUILD,RPMS,SPECS}
cp "$SCRIPT_DIR/aws-git-$GIT_AWS_RELEASE.patch" "$HOME"/rpmbuild/SOURCES/
AWS_SPEC_FILE="$HOME/rpmbuild/SPECS/aws-$GIT_AWS_RELEASE.spec"
rpm -q aws-sdk-cpp &>/dev/null &&  rpm -e aws-sdk-cpp

# Create spec file for RPM build
cat > "$AWS_SPEC_FILE" << EOF
Name:           aws-sdk-cpp
Version:        $GIT_AWS_RELEASE
Release:        0
Summary:        Amazon Web Services SDK for C++
License:        ASL 2.0
URL:            https://github.com/aws/%{name}
Patch0:         aws-git-$GIT_AWS_RELEASE.patch


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
git checkout $GIT_CHECKOUT_TAG

%patch0 -p1

%build
# Compiling the code
source /opt/rh/devtoolset-11/enable
cd %{_builddir}/aws-sdk-cpp/crt/aws-crt-cpp
cmake3 . -DBUILD_SHARED_LIBS=ON -DCPP_STANDARD=17 -DAUTORUN_UNIT_TESTS=OFF -DENABLE_TESTING=OFF -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DBYO_CRYPTO=ON -DCMAKE_INSTALL_PREFIX=%{buildroot}/usr/local/ && make -j $(nproc) install
cd ../..
cmake3 . -DBUILD_ONLY="s3;transfer" -DBUILD_SHARED_LIBS=ON -DCPP_STANDARD=17 -DAUTORUN_UNIT_TESTS=OFF -DENABLE_TESTING=OFF -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DBYO_CRYPTO=ON -DBUILD_DEPS=OFF -DCMAKE_INSTALL_PREFIX=%{buildroot}/usr/local/ && make -j $(nproc) install

%files
/usr/local/lib64/*
/usr/local/include/*

%clean
rm -rf aws-sdk-cpp
rm -rf %_buildrootdir/aws-sdk-cpp*

EOF

# Build AWS RPM
echo -n "Building AWS RPM ...."
if ! rpmbuild -bb "$AWS_SPEC_FILE";
then
    echo "[Failed]" 
    exit 1
fi
echo "[Success]"

find "$RPM_DIR" -name 'aws-sdk-cpp*.rpm' -exec cp {} "$ARTIFACTS_SCRIPT_DIR/" \;
