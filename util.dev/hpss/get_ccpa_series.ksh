#!/bin/ksh
set -x
day2=20180816
day1=20171001

day=$day2

while [ $day -ge $day1 ]
do
  ./get_ccpa.ksh $day
  day=`/nwprod/util/ush/finddate.sh $day d-1`
done

exit
