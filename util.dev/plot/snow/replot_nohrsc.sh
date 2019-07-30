#!/bin/bash
set -x
# Re-made NOHRSC plot from their grb2 (in case HOHRSC had an outage and 
# later re-made their files/plots.  NOHRSC's own 24h snow plot is also
# shown on my daily site.  Re-wget/re-send is done in 
# util.dev/rewget_nohrsc_img.ksh instead of here, because, ugh. 
# 
# optional argument: vday (yyyymmdd)
. ~/.bashrc
NDATE=/nwprod/util/exec/ndate
SCRIPT=/meso/save/Ying.Lin/pcpverif/nextjif/util.dev/plot/snow

if [ $# -eq 0 ]; then    
  today12z=`date -u +%Y%m%d`12
  vdate=`$NDATE -24 $today12z`
else                      
  vdate=${1}12
fi  

vmonth=${vdate:0:6}  # for wget nohrsc file
vday=${vdate:0:8}    # for wrkdir
vyear=${vdate:0:4}    # for wrkdir

wrkdir=/ptmpp1/Ying.Lin/replot_snowfall.$vday
if [ -d $wrkdir ]; then
  rm -f $wrkdir/*
else
  mkdir -p $wrkdir
fi

cd $wrkdir
# get NOHRSC 24h snowfall analysis, rename: 
wget -N https://www.nohrsc.noaa.gov/snowfall/data/${vmonth}/sfav2_CONUS_24h_${vdate}_grid184.grb2

if [ -s sfav2_CONUS_24h_${vdate}_grid184.grb2 ]; then 
  mv sfav2_CONUS_24h_${vdate}_grid184.grb2 nohrsc_asnow.$vdate.24h.grb2
  python $SCRIPT/plt_nohrsc_asnow.py nohrsc_asnow.$vdate.24h.grb2
  RZDMDIR=/home/www/emc/htdocs/mmb/ylin/pcpverif/daily
  scp nohrsc_asnow.${vday}12.24h.png wd22yl@emcrzdm:$RZDMDIR/$vyear/${vday}/.
fi

exit
   
