#!/bin/ksh
set -x
day1=20180623
day2=20180829
day=$day1

gaugedir=/ptmpp1/Ying.Lin/dlyprcp.dir
if [ ! -d $gaugedir ]
then 
  mkdir $gaugedir
fi

cd $gaugedir

while [ $day -le $day2 ];
do
  yyyy=${day:0:4}                 # alternative
  yyyymm=${day:0:6}
  HPSSDIR=/NCEPPROD/hpssprod/runhistory/rh$yyyy/$yyyymm/$day
  htar xvf $HPSSDIR/com_verf_prod_precip.$day.precip.tar \
    ./good-usa-dlyprcp-$day
  day=`/nwprod/util/ush/finddate.sh $day d+1`
done

exit

