#!/bin/ksh
set -x
#day=$1

datadir=/ptmpp1/Ying.Lin/vsdb_hpss
mkdir -p $datadir
cd $datadir

day1=20180802
day2=20180823
day=$day1

while [ $day -le $day2 ]; do
yyyy=${day:0:4}
yyyymm=${day:0:6}

hpssdir=/NCEPPROD/hpssprod/runhistory/rh$yyyy/$yyyymm/$day
htar xvf $hpssdir/com_verf_prod_vsdb_precip.$day.tar
day=`/nwprod/util/ush/finddate.sh $day d+1`

done

exit
