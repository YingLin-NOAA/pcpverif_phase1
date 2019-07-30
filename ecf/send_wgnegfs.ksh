#!/bin/ksh
set -x
#  send wgnegfs_* files to rzdm for int'l centers 
if [ $# -eq 0 ]; then   
  today=`date -u +%Y%m%d`
  daym1=`/nwprod/util/ush/finddate.sh $today d-1`
else 
  daym1=$1
fi
daym3=`/nwprod/util/ush/finddate.sh ${daym1} d-2`

# 2018/08/30: send fv3gfs QPF files to ftp.emc.ncep.noaa.gov for 
# int'l centers, so they can have an early look at it.
rzdmdir=/home/ftp/emc/mmb/precip/fv3gfs
# Only keep two days' worth of data on line:
ssh wd22yl@emcrzdm "rm -rf $rzdmdir/precip.$daym3; mkdir $rzdmdir/precip.$daym1"
cd /ptmpp1/Ying.Lin/verf.dat/precip.$daym1
scp wgnegfs_*.grb2 wd22yl@emcrzdm:$rzdmdir/precip.$daym1/.

exit


