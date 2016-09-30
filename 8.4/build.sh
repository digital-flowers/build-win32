#!/bin/bash

# the whole build process

. variables.sh

# export this to vips.modules ... cmake needs it
export BASEDIR=$basedir

vips_site=http://www.vips.ecs.soton.ac.uk/supported/$vips_version

# basic setup ... must do this before the native build, since it'll wipe the
# install area
./get-win32-packages.sh && \
  ./unpack.sh &&

# we need to do a native linux build to generate a typelib --
# the gobject-introspection machinery won't work in a cross-compiler
if [ ! -d $linux_install ]; then
  ( mkdir native-linux-build; cd native-linux-build; \
    vips_name=$vips_package-$vips_version.$vips_minor_version
    wget $vips_site/${vips_name}.tar.gz &&
    tar xf ${vips_name}.tar.gz &&
    cd $vips_name &&
    CFLAGS="-g" CXXFLAGS="-g" ./configure --prefix=$basedir/vips &&
    make &&
    make install )
fi

# do the win64 build and package
if [ -d $linux_install ]; then
  jhbuild --file=jhbuildrc build --nodeps libvips-$DEPS && \
    ./package-vipsdev.sh
fi