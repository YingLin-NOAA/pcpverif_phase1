#!/bin/ksh
set -x
day=$1

datadir=/ptmpp1/Ying.Lin/ccpa/ccpa.$day
mkdir -p $datadir
cd $datadir
yyyy=${day:0:4}
yyyymm=${day:0:6}

if [ $day -ge 20190812 ]; then
  ccpatar=gpfs_dell1_nco_ops_com_ccpa_prod_ccpa.$day.tar
else
  ccpatar=com2_ccpa_prod_ccpa.$day.tar
fi

hpssdir=/NCEPPROD/hpssprod/runhistory/rh$yyyy/$yyyymm/$day
htar xvf $hpssdir/$ccpatar \
  ./00/ccpa.t00z.06h.hrap.conus \
  ./06/ccpa.t06z.06h.hrap.conus \
  ./12/ccpa.t12z.06h.hrap.conus \
  ./18/ccpa.t18z.06h.hrap.conus

exit
