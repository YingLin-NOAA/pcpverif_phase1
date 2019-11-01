#!/bin/ksh
set -x
day1=20190925
day2=20190926

# start from the more recent date and go backwards, since later files on HPSS 
# are often quicker to retrieve.  
day=$day2

gaugedir=/gpfs/dell2/ptmp/Ying.Lin/dlyprcp.dir

if [ ! -d $gaugedir ]
then 
  mkdir $gaugedir
fi

cd $gaugedir

while [ $day -ge $day1 ];
do
  yyyy=${day:0:4}                 # alternative
  yyyymm=${day:0:6}
  HPSSDIR=/NCEPPROD/hpssprod/runhistory/rh$yyyy/$yyyymm/$day
  htar xvf $HPSSDIR/com_verf_prod_precip.$day.precip.tar \
    ./good-usa-dlyprcp-$day
  day=`/nwprod/util/ush/finddate.sh $day d-1`
done

exit

