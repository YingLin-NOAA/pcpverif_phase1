#!/bin/ksh
set -x
# rename all fv3sar_* QPF files to fv3sarda_*
# rename all fv3reg_* QPF files to fv3sar_*
#
# run this in the precip.yyyymmdd directory
#

VERFDAT=/ptmpp1/Ying.Lin/verf.dat
cd $VERFDAT

for daydir in `ls -1 | grep precip.`
do 
  cd $VERFDAT/$daydir
  for file in `ls -1 fv3sar_*`
  do
    newfile=`echo $file | sed 's/fv3sar/fv3sarda/'`
    mv $file $newfile
  done

  for file in `ls -1 fv3reg_*`
  do
    newfile=`echo $file | sed 's/fv3reg/fv3sar/'`
    mv $file $newfile
  done

done

exit
