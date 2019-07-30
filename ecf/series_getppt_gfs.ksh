#!/bin/ksh
set -x
day1=20171102
day2=20171118

day=$day1

# find current directory, since get_gfs_flux.ksh goes into data directory.  
SCRIPTDIR=`pwd`
while [ $day -le $day2 ]
do
  $SCRIPTDIR/jverf_precip_getppt.ecf $day retro
  day=`/nwprod/util/ush/finddate.sh $day d+1`
done


