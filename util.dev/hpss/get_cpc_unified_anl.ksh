#!/bin/ksh
set -x
day=$1

cd /stmpp1/Ying.Lin
yyyy=${day:0:4}
yyyymm=${day:0:6}

hpssdir=/NCEPPROD/hpssprod/runhistory/rh$yyyy/$yyyymm/$day
htar xvf $hpssdir/dcom_us007003_$day.tar ./wgrbbul/cpc_rcdas/PRCP_CU_GAUGE_V1.0GLB_0.25deg.lnx.$day.RT

exit
