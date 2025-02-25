#!/bin/sh -l

set -e

if [ $do_prepare = 1 ]
then
  case $buildsys in 
     ubuntu|debian)
       export DEBIAN_FRONTEND=noninteractive
       export LANG=C.UTF-8
       export LC_ALL=C.UTF-8
       apt-get update -q -y
       apt-get install -y --no-install-recommends $PACKAGES
       ;;
     almalinux)
       yum update -y
       yum install -y $PACKAGES
       . /opt/rh/gcc-toolset-11/enable
       ;;
     centos)
       yum update -y
       yum install -y centos-release-scl
       yum install -y $PACKAGES
       . /opt/rh/devtoolset-9/enable
       ;;
     alpine)
       apk update
       apk add --no-progress $PACKAGES
       ;;
     freebsd)
       env ASSUME_ALWAYS_YES=YES pkg install -y $PACKAGES
       ;;
     netbsd)
       pkg_add $PACKAGES
       ;;
     solaris)
       # pkg install pkg://solaris/developer/gcc-5
       # maybe only the following is enough, and fortran and gobjc needs not be installed?
       # pkg install pkg://solaris/developer/gcc/gcc-c++-5
       /opt/csw/bin/pkgutil -U
       /opt/csw/bin/pkgutil -y -i $PACKAGES
       ;;
     *)
       echo "Unsupported build system: $buildsys" >&2
       exit 1
       ;;
  esac
fi

# default settings
TL_MAKE_FLAGS="-j 2"
BUILDARGS=""

# special cases
case "$arch" in
  armhf-linux) # debian:buster
    TL_MAKE_FLAGS="-j 1"
    export CXXFLAGS='-std=c++17'
    ;;
  aarch64-linux) # debian:buster
    BUILDARGS="--enable-arm-neon=on"
    export CXXFLAGS='-std=c++17'
    ;;
  *-solaris)
    export PATH=/opt/csw/bin:$PATH
    export TL_MAKE=gmake
    if [ $arch = "i386-solaris" ]
    then
      export CC="gcc -m32"
      export CXX="g++ -m32"
    else
      export CC="gcc -m64"
      export CXX="g++ -m64"
    fi
    ;;
  *-freebsd)
    export TL_MAKE=gmake
    export CC=gcc
    export CXX=g++
    export CFLAGS=-D_NETBSD_SOURCE
    export CXXFLAGS='-D_NETBSD_SOURCE -std=c++17'
    ;;
  x86_64-linux|i386-linux|x86_64-linuxmusl)
    export CXXFLAGS='-std=c++17'
    ;;
esac
export TL_MAKE_FLAGS

