#!/bin/ksh
set -x
day=$1

datadir=/stmpp1/Ying.Lin/dcom/us007003/$day
mkdir -p $datadir
cd $datadir
yyyy=${day:0:4}
yyyymm=${day:0:6}

hpssdir=/NCEPPROD/hpssprod/runhistory/rh$yyyy/$yyyymm/$day
htar xvf $hpssdir/dcom_us007003_${day}.tar \
  ./qpf_verif/ukmo.${day}00 \
  ./qpf_verif/ukmo.${day}12

exit
