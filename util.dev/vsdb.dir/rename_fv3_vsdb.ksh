#!/bin/ksh
set -x

if [ $# -eq 1 ]; then
  day=$1
else
  today=`date +%Y%m%d`
  day=`/nwprod/util/ush/finddate.sh $today d-8`
fi

vsdbdir=/ptmpp1/Ying.Lin/verf.dat/vsdb
cd $vsdbdir/fv3sar

for file in `ls -1 fv3sar_*`
do 
  newfile=`echo $file | sed 's/fv3sar/fv3sarda/'`
  cat $file | sed 's/FV3SAR/FV3SARDA/g' > $newfile
  rm -f $file
done
cd $vsdbdir
mv fv3sar fv3sarda

cd fv3reg
for file in `ls -1 fv3reg_*`
do 
  newfile=`echo $file | sed 's/fv3reg/fv3sar/'`
  cat $file | sed 's/FV3REG/FV3SAR/g' > $newfile
  rm -f $file
done
cd $vsdbdir
mv fv3reg fv3sar

exit
