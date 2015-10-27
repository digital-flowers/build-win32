#!/bin/bash

. variables.sh

./clean.sh

for i in $packagedir/*win64.zip ; do
	echo installing $i
	( cd $installdir ; unzip -o -qq ../$i )
done

