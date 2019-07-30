#!/bin/ksh
set -x

# go to the day's tar file for precip.$yyyymmdd, extract QPF files for 
# nam_|gfs_|conusnest_|conusarw_|conusnmmb_|hrrr_ (used for 6-hourly FSS)

# Note that one should use 'egrep' for multiple models but simple 'grep' for
# a single model.  

day=$1
yyyy=`echo $day | cut -c 1-4`
yyyymm=`echo $day | cut -c 1-6`

#mkdir precip.$day
#cd precip.$day
# For this run, go directly to /ptmpp1/Ying.Lin/verf.dat/precip.$day

tarfile=/NCEPPROD/hpssprod/runhistory/rh${yyyy}/${yyyymm}/$day/com_verf_prod_precip.$day.precip.tar

#htar xvf $tarfile `htar tvf $tarfile | egrep 'nam_|gfs_|conusnest_|conusarw_|conusnmmb_|hrrr_' | awk '{ print $NF }'`
htar xvf $tarfile `htar tvf $tarfile | grep 'gfs_' | awk '{ print $NF }'`

exit
