#!/bin/bash

. variables.sh

# set -x

echo copying install area $installdir

rm -rf $repackagedir
cp -r $installdir $repackagedir

echo generating import files

./gendeflibs.sh

echo cleaning build $repackagedir

( cd $repackagedir ; rm -rf _jhbuild )

for i in COPYING ChangeLog README.md AUTHORS; do
  ( cp $basedir/$checkoutdir/vips-$vips_version/$i $repackagedir )
done

# rename all the $mingw_prefix-animate etc. without the prefix
( cd $repackagedir/bin ; for i in $mingw_prefix*; do mv $i `echo $i | sed s/$mingw_prefix//`; done )

# clean /bin
( cd $repackagedir/bin ; mkdir ../poop ; mv *vips* ../poop ; mv *.dll ../poop ; rm -f * ; mv ../poop/* . ; rmdir ../poop )

( cd $repackagedir/bin ; rm -f vips-8.* )

( cd $repackagedir/bin ; strip --strip-unneeded *.exe )

# for some reason we can't strip zlib1
( cd $repackagedir/bin ; mkdir poop ; mv zlib1.dll poop ; strip --strip-unneeded *.dll ; mv poop/zlib1.dll . ; rmdir poop )

( cd $repackagedir/share ; rm -rf aclocal glib-2.0 gtk-2.0 info jhbuild man xml themes )

( cd $repackagedir/share/gtk-doc/html ; mkdir ../poop ; mv libvips ../poop ; rm -rf * ; mv ../poop/* . ; rmdir ../poop )

# we only support GB and de locales
( cd $repackagedir/share/locale ; mkdir ../poop ; mv en_GB de ../poop ; rm -rf * ; mv ../poop/* . ; rmdir ../poop )
( cd $repackagedir/share/locale ; find . -name "gtk*.mo" -exec rm {} \; )
( cd $repackagedir/share/locale ; find . -name "atk*.mo" -exec rm {} \; )

( cd $repackagedir/include ; rm -rf atk-1.0 cairo gtk-2.0 libglade-2.0 )

( cd $repackagedir ; rm -rf make man manifest src )

( cd $repackagedir/etc ; rm -rf gtk-2.0 gconf )

( cd $repackagedir/lib ; rm -rf *atk* *cairo* *gdk* *gtk*  )
( cd $repackagedir/lib ; find . -name "*.la" -exec rm {} \; )

# we need to copy the C++ runtime dlls in there
gccmingwlibdir=/usr/lib/gcc/i686-w64-mingw32/*-win32
cp $gccmingwlibdir/*.dll $repackagedir/bin

# don't need these two
( cd $repackagedir/bin ; rm -f libgomp*.dll )
( cd $repackagedir/bin ; rm -f libgfortran*.dll )

# stuff for pyvips8, assumes presence of $linux_install/lib/girepository-1.0
if [ -f $linux_install/lib/girepository-1.0/Vips-8.0.typelib ]; then
  mkdir -p $repackagedir/lib/girepository-1.0
  cp $linux_install/lib/girepository-1.0/Vips-8.0.typelib $repackagedir/lib/girepository-1.0
  mkdir -p $repackagedir/lib/python2.7/site-packages/gi/overrides
  cp $linux_install/lib/python2.7/site-packages/gi/overrides/Vips.* $repackagedir/lib/python2.7/site-packages/gi/overrides
else
  echo WARNING: could not find lib/girepository-1.0 for pyvips8 support
fi

# ... and test we startup OK
echo -n "testing build ... "
wine $repackagedir/bin/vips.exe --help > /dev/null
if [ "$?" -ne "0" ]; then
  echo WARNING: vips.exe failed to run
else
  echo ok
fi

zipfile=$vips_package-dev-w32-$DEPS-$vips_version.$vips_minor_version.zip
echo creating $zipfile
rm -f $zipfile
zip -r -qq $zipfile $repackagedir
