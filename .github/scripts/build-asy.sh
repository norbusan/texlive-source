#!/bin/sh -l

set -e

if [ "x$2" = "x" ]
then
  echo "Usage: `basename $0` arch buildsys [no-prepare]" >&2
  exit 1
fi

arch="$1"
echo "Building TL asy for arch = $arch"
shift

buildsys=$1
echo "Building on $buildsys"
shift

do_prepare=1
if [ "$1" = "no-prepare" ]
then
  do_prepare=0
fi
export do_prepare


case $buildsys in 
  ubuntu|debian)
    PACKAGES="bash gcc g++ make perl libfontconfig-dev libx11-dev libxmu-dev libxaw7-dev build-essential libtool-bin build-essential pkg-config libeigen3-dev libcurl4-openssl-dev libreadline-dev libboost-filesystem-dev flex libglu1-mesa-dev freeglut3-dev libosmesa6-dev libreadline6-dev zlib1g-dev bison libglm-dev libncurses-dev python3 libtirpc-dev"
    ;;
  almalinux)
    PACKAGES="gcc-toolset-11 fontconfig-devel libX11-devel libXmu-devel libXaw-devel"
    ;;
  centos)
    PACKAGES="devtoolset-9 fontconfig-devel libX11-devel libXmu-devel libXaw-devel"
    ;;
  alpine)
    PACKAGES="bash gcc g++ make perl fontconfig-dev libx11-dev libxmu-dev libxaw-dev"
    ;;
  freebsd)
    PACKAGES="gmake gcc pkgconf libX11 libXt libXaw fontconfig perl5 eigen readline flex libGLU freeglut libosmesa zlib-ng bison glm ncurses python python3 libtool"
    ;;
  netbsd)
    PACKAGES="gmake gcc pkgconf libX11 libXt libXaw fontconfig perl5"
    ;;
  solaris)
    PACKAGES="autoconf automake gcc5core libtool gmake gcc pkgconf libX11 libXt libXaw fontconfig perl5 eigen readline flex libGLU freeglut libosmesa zlib-ng bison glm ncurses python python3"
    ;;
  *)
    echo "Unsupported build system: $buildsys" >&2
    exit 1
    ;;
esac
export PACKAGES

source .github/scripts/setup.sh

# Actual build job

find . -name \*.info -exec touch '{}' \;
touch ./utils/asymptote/camp.tab.cc
touch ./utils/asymptote/camp.tab.h
touch ./configure ./Makefile.in

cd utils/asymptote
./configure --prefix=/tmp/asyinst --enable-static --enable-texlive-build \
	--disable-gsl --disable-fftw --disable-lsp --disable-curl
	LDFLAGS="-static-libgcc -static-libstdc++"
$TL_MAKE SILENT_MAKE= -j2

strip asy

mv asy ../../asy-$arch

