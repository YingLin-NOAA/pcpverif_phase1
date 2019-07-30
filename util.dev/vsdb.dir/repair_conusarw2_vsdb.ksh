#!/bin/ksh
set -x
#
day1=20180122
day2=20180129
model=conusarw2
wrkdir=/stmpp1/Ying.Lin/repair_vsdb

if [ -d $wrkdir ]
then
  rm -f $wrkdir/*
else
  mkdir -p $wrkdir
fi
cd $wrkdir

tempestvsdb=/export-4/tempest/wd22yl/vsdb/$model
wcossvsdb=/com/verf/prod/vsdb/precip/$model
day=$day1
while [ $day -le $day2 ]
do
  vsdbfile=${model}_${day}.vsdb
  cp $wcossvsdb/$vsdbfile .
  scp wd22yl@tempest:$tempestvsdb/$vsdbfile tmp.vsdb
  cat tmp.vsdb >> $vsdbfile
  day=`/nwprod/util/ush/finddate.sh $day d+1`
done

exit

  
