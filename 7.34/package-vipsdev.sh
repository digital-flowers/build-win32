#!/bin/bash

. variables.sh

mingw_prefix=i686-pc-mingw32-

# set -x

repackagedir=$vips_package-dev-$vips_version

echo copying install area $installdir

rm -rf $repackagedir
cp -r $installdir $repackagedir

echo cleaning build $repackagedir

# rename all the $mingw_prefix-animate etc. without the prefix
( cd $repackagedir/bin ; for i in $mingw_prefix*; do mv $i `echo $i | sed s/$mingw_prefix//`; done )

( cd $repackagedir/bin ; mkdir ../poop ; mv *vips* ../poop ; mv *.dll ../poop ; rm -f * ; mv ../poop/* . ; rmdir ../poop )

( cd $repackagedir/bin ; rm libatk* libglade* libgtk* )
( cd $repackagedir/bin ; rm vips-7.* )

( cd $repackagedir/bin ; strip --strip-unneeded *.exe )

# for some reason we can't strip zlib1
( cd $repackagedir/bin ; mkdir poop ; mv zlib1.dll poop ; strip --strip-unneeded *.dll ; mv poop/zlib1.dll . ; rmdir poop )

( cd $repackagedir/share ; rm -rf aclocal glib-2.0 gtk-2.0 info jhbuild man xml themes )

( cd $repackagedir/share/doc ; mkdir ../poop ; mv vips ../poop ; rm -rf * ; mv ../poop/* . ; rmdir ../poop )
( cd $repackagedir/share/doc/vips ; rm -rf pdf )

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
mingwlibdir=/usr/lib/gcc/i686-w64-mingw32/4.6
cp $mingwlibdir/*.dll $repackagedir/bin

# ... and test we startup OK
echo -n "testing build ... "
$repackagedir/bin/vips.exe --help > /dev/null
if [ "$?" -ne "0" ]; then
	echo vips.exe failed to run argh
	exit 1
fi
echo ok

echo creating $vips_package-dev-$vips_version.zip
rm -f $vips_package-dev-$vips_version.zip
zip -r -qq $vips_package-dev-$vips_version.zip $vips_package-dev-$vips_version
