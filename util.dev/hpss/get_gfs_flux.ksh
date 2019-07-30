#!/bin/ksh
set -x
day=$1
datadir=/ptmpp1/Ying.Lin/gfs
# output will be in $datadir/gpfs/hps/nco/ops/com/gfs/prod/gfs.$day
if [ ! -d $datadir ]; then mkdir -p $datadir; fi

cd $datadir

yyyy=${day:0:4}
yyyymm=${day:0:6}

hpssdir=/NCEPPROD/hpssprod/runhistory/rh$yyyy/$yyyymm/$day
for hh in 00 06 12 18
do 
  htar xvf $hpssdir/gpfs_hps_nco_ops_com_gfs_prod_gfs.${day}${hh}.sfluxgrb.tar
done

exit
