#!/bin/ksh
set -x

mkdir ../fv3gfs

for file in `ls -1`
do 
  newfile=`echo $file | sed 's/glbfv3/fv3gfs/'`
  cat $file | sed 's/GLBFV3/FV3GFS/' > ../fv3gfs/$newfile
done

exit
