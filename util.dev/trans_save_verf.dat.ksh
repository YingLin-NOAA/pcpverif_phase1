#!/bin/ksh
#BSUB -J save_verf_dat
#BSUB -oo /ptmpp1/Ying.Lin/cron.out/save_verf_dat.%J
#BSUB -eo /ptmpp1/Ying.Lin/cron.out/save_verf_dat.%J
#BSUB -cwd /stmpp1/Ying.Lin
#BSUB -n 1
#BSUB -q "transfer"
#BSUB -W 1:58
#BSUB -R "rusage[mem=300]"
#BSUB -R "affinity[core]"
#BSUB -P VERF-T2O
# 
# Data transfer job: tars up the contents of /ptmpp1/Ying.Lin/verf.dat, 
# send a copy to HPSS, another copy to tempest.
# 
# This job is normally submitted at the end of jobs/JVERF_PRECIP_FSS_24H, 
# i.e. to be done after the day's CONUS verification (including
# verfgen24, verfgen03, verfplot, FSS) is completed.  
#
set -x
# invoke .profile to load HPSS module, otherwise hsi would not work under cron.
. ~/.profile 

date

if [ $# -eq 0 ]; then  
  day=`date -u +%Y%m%d`
else                  
  day=$1
fi
#

daym1=`/nwprod/util/ush/finddate.sh $day d-1`

cd /ptmpp1/Ying.Lin/verf.dat

tar cvfz /stmpp1/Ying.Lin/verf.dat.$daym1.gz .

cd /stmpp1/Ying.Lin
#2016/10/31 temporarily turning off send to HPSS (see NCO email)
#hsi "cd /1year/NCEPDEV/emc-meso/Ying.Lin/verf.sss; put verf.dat.$daym1.gz" 
scp verf.dat.$daym1.gz wd22yl@tempest:/export-4/tempest/wd22yl/verf.sss/.

date

exit

