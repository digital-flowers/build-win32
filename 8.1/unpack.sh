#!/bin/bash

. variables.sh

./clean.sh

for i in $packagedir/*win32.zip ; do
	echo installing $i
	( cd $installdir ; unzip -o -qq ../$i )
done

