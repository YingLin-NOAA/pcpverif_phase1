#!/bin/ksh
set -x
#
# Compute/plot URMA and CMORPH 24h total from 6h totals
#   In retro mode, compute/plot URMA 24h total only (for 7-day reruns)
#
if [ $# -eq 0 ]; then
  today=`date +%Y%m%d`
  day=`/nwprod/util/ush/finddate.sh $today d-1`
else
  day=$1
fi

wrkdir=/stmpp1/Ying.Lin/pcpurma_cmorph_daily_sum

anlpfx=/com2/urma/prod/pcpurma

if [ -d $wrkdir ]; then
  rm -f $wrkdir/*
else
  mkdir -p $wrkdir
fi
cd $wrkdir

NDATE=/nwprod/util/exec/ndate
WGRIB2=/nwprod2/pcpanl.v3.1.0/lib/grib2/wgrib2/wgrib2

# for wgrib2 summing: 
refdate=`$NDATE -24 ${day}12`

# Sum up CMORPH and URMA from 6-hourly

if [ $retro = YES ]; then
  anls="pcpurma"
else
  anls="cmorph pcpurma"
fi

for anl in $anls
do 
  anl24h=$anl.${day}12.24h

  aok=YES
  date6h=`$NDATE -18 ${day}12`

  while [ $date6h -le ${day}12 ];
  do
    day6h=${date6h:0:8}
    if [ $anl = cmorph ]; then
      anl6h=cmorph.$date6h.06h.wexp
    elif [ $anl = pcpurma ]; then
      anl6h=pcpurma_wexp.$date6h.06h.grb2
    fi

    if [ -s $anlpfx.$day6h/$anl6h ]; then
      echo $anlpfx.$day6h/$anl6h >> input_acc_$anl 
    else
      aok=NO
    fi
    date6h=`$NDATE +6 ${date6h}`
  done

  if [ $aok = YES ]; then
    cat `cat input_acc_$anl` | $WGRIB2 - -ave 6hr $anl.ave.grb
    $WGRIB2 $anl.ave.grb -rpn "4:*" -set_date $refdate -set_ave "0-24 hour ave anl" -set_scaling -1 0 -grib_out $anl24h
    python /meso/save/Ying.Lin/pcpanl/urma.v2.7.0/util.dev/plt_pcpurma.py $anl24h conus
    gzip $anl24h
    cp $anl24h.gz /meso/noscrub/Ying.Lin/test/noscrub/daily/.
  fi
done
year=${day:0:4}
rzdmdir=/home/www/emc/htdocs/mmb/ylin/pcpverif/daily/$year/$day
ssh wd22yl@emcrzdm "mkdir -p $rzdmdir"
scp *.png wd22yl@emcrzdm:$rzdmdir/.
exit



  



