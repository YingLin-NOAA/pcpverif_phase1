#!/bin/ksh
# 
# Data transfer job: to be done prior to submission of each day's getppt.
#
# Also 'touch' the precip.$day files and vsdb files for FSS06H.
# 
# The second half of the job, 'get verf.dat from hpss or tempest', is not
# really set up to automatically go fetch on the data on the new devwcoss
# to populate the new devwcoss' /ptmpp1/Ying.Lin/verf.dat
# after a prod/dev switch on wcoss.  Invoke this feature manually by typing
#      trans_pre_getppt.ksh $daym1 fetch
# 
# 'touch -c' would not create an empty file, if one does not already exist.

set -x

# invoke .profile to load HPSS module, otherwise hsi would not work under cron.
. ~/.profile 

if [ $# -eq 0 ]; then  
  today=`date -u +%Y%m%d`
  day=`/nwprod/util/ush/finddate.sh $today d-1`
else                  
  day=$1
fi

if [ $# -gt 1 -a $2 = fetch ]; then  
  fetchverfdat=yes
else
  fetchverfdat=no
fi

#
COMOUT=/ptmpp1/$LOGNAME/verf.dat/precip.
COMVSDB=/ptmpp1/$LOGNAME/verf.dat/vsdb

# get HPC QPF:
RZDM=wd22yl@emcrzdm:/home/ftp/hpc/grib/$day

if ! [ -d $COMOUT$day ]; then
  mkdir -p $COMOUT$day
fi

typeset -Z3 fhr1 fhr2

for cyc in 00 06 12 18
do

  fhr1=000
  fhr2=006
  if [ $cyc -eq 00 -o $cyc -eq 12 ]; then
    frange=72
  else
    frange=54
  fi

  while [ $fhr2 -le $frange ]; do
    scp $RZDM/p06m_${day}${cyc}f${fhr2}.grb \
    $COMOUT$day/hpc_${day}${cyc}_${fhr1}_${fhr2}
    let fhr1=fhr2
    let fhr2=fhr2+6
  done
done 

# 'touch' select files in precip.$day for daym14 - daym3. 
# For FSS06H, we need daym14-daym10 on line.  We are touching them as far
# back as daym14 to provide some safety margin - in case we need to make 
# re-runs a couple of days later.
#

daytouch=`/nwprod/util/ush/finddate.sh $day d-14`
daym3=`/nwprod/util/ush/finddate.sh $day d-3`

parmdir=/meso/save/Ying.Lin/pcpverif/nextjif/parm.dev.wcoss
# find out which models are being verified in FSS06H:
models=`grep '=1' $parmdir/verf_precip_fss_06h_config | sed 's/export run_//g' | sed 's/=1//g'`
# Add the non-FSS06H models whose files also need to be kept on line:
models=`echo $models`

while [ $daytouch -le $daym3 ]; do
  for model in `echo $models`
  do 
    cd $COMOUT$daytouch
    err=$?
    if [ $err -eq 0 ]; then
      touch -c ${model}_*
    fi
    cd $COMVSDB/$model
    if [ $err -eq 0 ]; then
      touch -c ${model}_${daytouch}.vsdb
    fi
  done
  daytouch=`/nwprod/util/ush/finddate.sh $daytouch d+1`
done

if [ $fetchverfdat = no ]; then 
  exit 
fi

# If we are here, then we shall fetch previous day's archive of verf.dat.
# if the previous day's verif is done on the OTHER wcoss machine, go to HPSS to
# fetch the data.
daym1=`/nwprod/util/ush/finddate.sh $day d-1`

fetchdir=/stmpp1/Ying.Lin/fetch.verf.sss
if ! [ -d $fetchdir ]; then
  mkdir -p $fetchdir
fi

cd $fetchdir
hsi "cd /1year/NCEPDEV/emc-meso/Ying.Lin/verf.sss; get verf.dat.$daym1.gz" 

if ! [ -s verf.dat.$daym1.gz ]; then
  scp wd22yl@tempest:/export-4/tempest/wd22yl/verf.sss/verf.dat.$daym1.gz .
fi

if [ -s verf.dat.$daym1.gz ]; then
  cd /ptmpp1/Ying.Lin/verf.dat
  tar xvf $fetchdir/verf.dat.$daym1.gz
else
  echo verf.dat.$daym1.gz not found on either HPSS or tempest.  EXIT.
fi

exit

