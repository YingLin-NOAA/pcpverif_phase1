#!/bin/ksh
# For tests before code release, populate earlier days of verf.dat/precip.$day
# with 
#  1) prod precip.$day
#  2) para precip.$day's rapx_*, hrrrx_* and hrrrakx_* files, change
#     the names to rap_*, hrrr_* and hrrrak_*
#
set -x
day1=20180122
day2=20180129

day=$day1

while [ $day -le $day2 ]
do
  DIR1=/ptmpp1/Ying.Lin/verf.dat/precip.$day
  DIR2=/ptmpp1/Ying.Lin/verf.dat.v4.1.0/precip.$day
  cd $DIR1
  for file in `ls -1 rapx_*`
  do
    newfile=`echo $file | sed 's/rapx/rap/'`
    cp $file $DIR2/$newfile
  done

  for file in `ls -1 hrrrx_*`
  do
    newfile=`echo $file | sed 's/hrrrx/hrrr/'`
    cp $file $DIR2/$newfile
  done

  for file in `ls -1 hrrrakx_*`
  do
    newfile=`echo $file | sed 's/hrrrakx/hrrrak/'`
    cp $file $DIR2/$newfile
  done
  day=`/nwprod/util/ush/finddate.sh $day d+1`
done


