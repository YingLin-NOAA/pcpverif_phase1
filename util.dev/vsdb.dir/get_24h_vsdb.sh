#!/bin/sh
set -x
# Made reruns for missing verfgen24h run for fv3sar.  To load the missing 
# 24h VSDBs to METviewer server without loading the already-loaded 3h and 6h
# vsdbs, get the 24h-only vsdb from precip.$day/vsdb24.$day.tar.
#
day1=20190817
day2=20190904
day=$day1

savedir=/meso/save/Ying.Lin/fv3sar.vsdb.dir
cd $savedir
while [ $day -le $day2 ]
do
  tar xvf /ptmpp1/Ying.Lin/verf.dat/precip.$day/vsdb24.$day.tar
  day=`/nwprod/util/ush/finddate.sh $day d+1`
done

  
